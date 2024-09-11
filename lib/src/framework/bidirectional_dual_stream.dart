import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

abstract class IBidirectionalDualStream<R,S> implements StreamSink<S> {
  Stream<R> get receiver;
  bool get isActive;

  const IBidirectionalDualStream();

  
}

class BidirectionalDualStreamFactory<R,S> extends IBidirectionalDualStream<R,S>  {
  StreamController<R>? _receiver;
  StreamController<S>? _sender;
  StreamSubscription<R>? _subcription;

  final _complete = Completer();
  final _waitInitialize = Completer();

  bool _isActive = false;
  bool _isInicializer = false;

  BidirectionalDualStreamFactory();

  factory BidirectionalDualStreamFactory.initialized({
    required Stream<R> receiver,
    required StreamSink<S> sender,
    required bool closeExternalStreamIfClose,
  }) {
    final item = BidirectionalDualStreamFactory<R,S>();
    item.initializeStream(receiver: receiver, sender: sender, closeExternalStreamIfClose: closeExternalStreamIfClose);
    return item;
  }

  Future<void> waitInitialize() async {
    if (_isInicializer) {
      _checkActivity();
      return;
    }

    return _waitInitialize.future;
  }

  void initializeStream({
    required Stream<R> receiver,
    required StreamSink<S> sender,
    required bool closeExternalStreamIfClose,
  }) {
    if (_isInicializer) {
      throw NegativeResult(
        identifier: NegativeResultCodes.uninitializedFunctionality,
        message: tr('Bidirectional Stream has already been initialized'),
      );
    }

    _generateReceive(receiver: receiver);
    _generateSender(sender: sender, closeExternalStreamIfClose: closeExternalStreamIfClose);

    _isInicializer = true;
    _isActive = true;

    _waitInitialize.complete();
  }

  void _generateReceive({required Stream<R> receiver}) {
    _receiver = StreamController<R>.broadcast();
    _subcription = receiver.listen(
      (x) {
        _receiver!.add(x);
      },
      onError: (x, y) {
        _receiver!.addError(x, y);
      },
      onDone: () {
        close();
      },
    );
  }

  void _generateSender({required StreamSink<S> sender, required bool closeExternalStreamIfClose}) {
    _sender = StreamController<S>();
    _sender!.stream.listen(
      (x) => sender.add(x),
      onError: (x, y) => sender.addError(x, y),
      onDone: () {
        if (closeExternalStreamIfClose) {
          sender.close();
        }
      },
    );

    sender.done.whenComplete(() => close());
  }

  void _checkInicializer() {
    if (!_isInicializer) {
      throw NegativeResult(
        identifier: NegativeResultCodes.uninitializedFunctionality,
        message: tr('Bidirectional Stream was not initialized'),
      );
    }
  }

  void _checkActivity() {
    if (!_isActive) {
      throw NegativeResult(
        identifier: NegativeResultCodes.uninitializedFunctionality,
        message: tr('Bidirectional Stream is not active'),
      );
    }
  }

  @override
  Stream<R> get receiver {
    _checkInicializer();
    _checkActivity();
    return _receiver!.stream;
  }

  @override
  Future get done => _complete.future;

  @override
  bool get isActive => _isActive;

  @override
  void add(S event) {
    _checkInicializer();
    _checkActivity();
    _sender!.add(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _checkInicializer();
    _checkActivity();
    _sender!.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<S> stream) async {
    _checkInicializer();
    _checkActivity();

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

    _subcription?.cancel();
    _receiver?.close();
    _sender?.close();
    _complete.complete();
  }
}

