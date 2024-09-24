import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:meta/meta.dart';

mixin IReactiveFunctionality<S, R> implements StreamSink {
  bool get isActive;
  Stream<S> get stream;

  void wakeUp();

  void start();

  void connect<SE, RE>({required Stream<RE> input, required StreamSink<SE> output});
}

abstract class ReactiveFunctionalityImplementation<S, R> implements IReactiveFunctionality<S, R> {
  final _spectators = <_SpectatorReactiveFunctionality>[];

  @protected
  Stream<S> runFunction();

  @protected
  void reactExternalDataReceived(R data);

  @protected
  void reactExternalErrorReceived(error);

  bool get closeIfSpectatorsEmptry;

  StreamController<R>? _receiver;
  StreamSubscription<R>? _subscriptionReceiver;

  StreamSubscription<S>? _subscriptionSender;
  StreamController<S>? _streamer;

  Completer<R>? _waiterData;
  Completer? _waiterSleep;
  Completer? _waiterActiveStream;

  bool _isActive = false;
  bool _wantCancel = false;

  final _semaphoneInitializing = Semaphore();

  @override
  bool get isActive => _isActive;

  @override
  Stream<S> get stream {
    _checkActive();
    return _streamer!.stream;
  }

  @override
  Future get done {
    _checkActive();
    return _streamer!.done;
  }

  void _checkActive() {
    if (!_isActive) {
      throw NegativeResult(
        identifier: NegativeResultCodes.uninitializedFunctionality,
        message: tr('Bidirectional Stream was not active'),
      );
    }
  }

  @override
  void start() {
    _semaphoneInitializing.executeIfStopped(function: _asyncStart);
  }

  Future<void> _asyncStart() async {
    if (_isActive) {
      return;
    }

    if (_waiterActiveStream != null && !_waiterActiveStream!.isCompleted) {
      log('[Reactive functionality] Current stream active, waiting for completion to continue');
      await _waiterActiveStream!.future;
      log('[Reactive functionality] Current stream was clodes, continue');
    }

    _wantCancel = false;
    _waiterActiveStream = Completer();

    _receiver = StreamController<R>();
    _streamer = StreamController<S>.broadcast();

    _subscriptionReceiver = _receiver!.stream.listen(
      _receiverSendData,
      onError: _receiverSendError,
    );

    scheduleMicrotask(() {
      _spectators.iterar((x) => x.start());
      _subscriptionSender = runFunction().listen(
        (x) {
          checkState();
          _streamer?.add(x);
          _spectators.iterar((s) => s.add(x));
        },
        onError: (x, y) {
          _streamer!.addError(x, y);
          _spectators.iterar((s) => s.addError(x, y));
        },
        onDone: () {
          _wantCancel = false;
          _subscriptionSender = null;
          _waiterActiveStream?.complete();
          _waiterActiveStream = null;
          close();
        },
      );
    });

    _isActive = true;
  }

  void _receiverSendData(R data) {
    if (_waiterData != null && !_waiterData!.isCompleted) {
      _waiterData!.complete(data);
      _waiterData = null;
    }
    reactExternalDataReceived(data);
  }

  void _receiverSendError(error) {
    if (_waiterData != null && !_waiterData!.isCompleted) {
      _waiterData!.completeError(error);
      _waiterData = null;
    }
    reactExternalErrorReceived(error);
  }

  @override
  void add(dynamic event) {
    _checkActive();

    if (event is R) {
      _receiver!.add(event);
    } else {
      _streamer!.addError(NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: tr('The functionality only accepts receiving objects of type %1, but a packet of type %2 was received', [R, event.runtimeType]),
      ));
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _checkActive();
    _receiver!.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream stream) async {
    _checkActive();
    final completer = Completer();

    final subscription = stream.listen(
      (x) {
        if (_isActive) {
          add(x);
        }
      },
      onDone: () => completer.complete(),
    );

    final futureDone = done.whenComplete(() => subscription.cancel());

    await completer.future;
    futureDone.ignore();
  }

  @override
  Future close() async {
    if (!_isActive) {
      return;
    }

    _isActive = false;

    if (_waiterData != null) {
      _waiterData!.completeError(NegativeResult(identifier: NegativeResultCodes.functionalityCancelled, message: tr('The functionality was canceled')));
      _waiterData = null;
      await Future.delayed(Duration.zero);
    }

    if (_waiterSleep != null) {
      _waiterSleep!.completeError(NegativeResult(identifier: NegativeResultCodes.functionalityCancelled, message: tr('The functionality was canceled')));
      _waiterSleep = null;
      await Future.delayed(Duration.zero);
    }

    _wantCancel = true;

    _subscriptionReceiver?.cancel();
    _subscriptionReceiver = null;

    _receiver?.close();
    _streamer?.close();

    _receiver = null;
    _streamer = null;

    _spectators.iterar((x) => x.close());
    _spectators.clear();
  }

  Future<void> sleep({required Duration duration}) async {
    _waiterSleep = Completer();
    final timer = Timer(duration, () {
      if (_waiterSleep != null && !_waiterSleep!.isCompleted) {
        _waiterSleep!.complete();
      }
    });

    await _waiterSleep!.future.whenComplete(() => timer.cancel());

    _waiterSleep = null;
  }

  @override
  void wakeUp() {
    if (_waiterSleep != null && !_waiterSleep!.isCompleted) {
      _waiterSleep!.complete();
    }
  }

  void checkState() {
    if (_wantCancel) {
      _wantCancel = false;
      _subscriptionSender!.cancel().whenComplete(() {
        _waiterActiveStream?.complete();
        _waiterActiveStream = null;
      });

      //throw NegativeResult(identifier: NegativeResultCodes.functionalityCancelled, message: tr('The functionality was canceled'));
    }
  }

  Future<R> waitReceiveData() {
    checkState();
    if (_waiterData == null || _waiterData!.isCompleted) {
      _waiterData = Completer<R>();
    }

    return _waiterData!.future.whenComplete(() {
      _waiterData = null;
      checkState();
    });
  }

  Future<T> waitFunction<T>(Future<T> Function() function) async {
    _waiterSleep = Completer<T>();

    Future functionInstance = function().then((x) => _waiterSleep?.complete(x)).catchError((x, y) => _waiterSleep?.completeError(x, y));

    return await _waiterSleep!.future.whenComplete(() => functionInstance.ignore());
  }

  Future<R?> waitWhileForData({required Duration duration}) {
    checkState();
    final waiter = Completer<R?>();
    late final Timer timer;
    late final Future waiting;

    waiting = waitReceiveData().then((x) {
      if (!waiter.isCompleted) {
        waiter.complete(x);
      }
    }).onError((x, y) {
      if (!waiter.isCompleted) {
        waiter.completeError(x!, y);
      }
    }).whenComplete(() => timer.cancel());

    timer = Timer(duration, () {
      if (!waiter.isCompleted) {
        waiter.complete(null);
      }

      waiting.ignore();
    });

    return waiter.future.whenComplete(() => checkState());
  }

  @override
  void connect<SE, RE>({required Stream<RE> input, required StreamSink<SE> output}) {
    final newSpectator = _SpectatorReactiveFunctionality<S, R, SE, RE>(input: input, output: output, parent: this);
    newSpectator.done.whenComplete(() => _removeSpectator(newSpectator));

    if (_isActive) {
      newSpectator.start();
    } else {
      start();
    }

    _spectators.add(newSpectator);
  }

  void _removeSpectator(_SpectatorReactiveFunctionality item) {
    _spectators.remove(item);
    if (closeIfSpectatorsEmptry && _spectators.isEmpty) {
      close();
    }
  }
}

class _SpectatorReactiveFunctionality<S, R, SE, RE> {
  final IReactiveFunctionality<S, R> parent;
  final Stream<RE> input;
  final StreamSink<SE> output;

  late final StreamSubscription subscription;

  bool _isActive = false;
  final _doneCompleter = Completer();

  _SpectatorReactiveFunctionality({required this.parent, required this.input, required this.output});

  void start() {
    if (_isActive) {
      return;
    }

    subscription = input.listen(
      (x) {
        parent.add(x);
      },
      onError: (x, y) {
        parent.addError(x, y);
      },
      onDone: close,
    );

    output.done.whenComplete(close);

    _isActive = true;
  }

  void add(event) {
    if (!_isActive) {
      return;
    }

    if (event is SE) {
      output.add(event);
    } else {
      output.addError(NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: tr('The output does not accept the message the functionality is trying to send (%1 is incompatible with %2)', [event.runtimeType.toString(), SE.toString()]),
      ));
    }
  }

  void addError(Object error, [StackTrace? stackTrace]) {
    if (!_isActive) {
      return;
    }
    output.addError(error, stackTrace);
  }

  Future close() async {
    if (!_isActive) {
      return;
    }

    _isActive = false;

    subscription.cancel();
    output.close();

    _doneCompleter.complete();
  }

  Future get done => _doneCompleter.future;
}
