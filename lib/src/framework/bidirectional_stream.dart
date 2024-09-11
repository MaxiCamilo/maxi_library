import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

abstract class IBidirectionalStream<T> implements StreamSink<T> {
  Stream<T> get receiver;
  bool get isActive;

  const IBidirectionalStream();

  void joinWithOther({required IBidirectionalStream<T> other, required bool selfCloseIfStreamClosed, required bool closeExternalStreamIfClose}) {
    joinWithStream(stream: other.receiver, selfCloseIfStreamClosed: selfCloseIfStreamClosed);
    joinWithSick(sink: other, closeExternalStreamIfClose: closeExternalStreamIfClose);
  }

  void joinWithController({required StreamController<T> controll, required bool selfCloseIfStreamClosed, required bool closeExternalStreamIfClose}) {
    joinWithStream(stream: controll.stream, selfCloseIfStreamClosed: selfCloseIfStreamClosed);
    joinWithSick(sink: controll, closeExternalStreamIfClose: closeExternalStreamIfClose);
  }

  void joinWithSick({required StreamSink<T> sink, required bool closeExternalStreamIfClose}) {
    late final Future<void> doneSubcription;

    receiver.listen(
      (x) => sink.add(x),
      onError: (x, y) => sink.addError(x, y),
      onDone: () {
        if (closeExternalStreamIfClose) {
          sink.close();
        }

        doneSubcription.ignore();
      },
    );

    doneSubcription = sink.done.whenComplete(() {
      close();
    });
  }

  void joinWithStream({required Stream<T> stream, required bool selfCloseIfStreamClosed}) {
    late final Future<dynamic> doneSunscription;
    final subscription = stream.listen(
      (x) => add(x),
      onError: (x) => addError(x),
      onDone: () {
        if (selfCloseIfStreamClosed) {
          close();
        }
        doneSunscription.ignore();
      },
    );

    doneSunscription = done.whenComplete(() => subscription.cancel());
  }
}

class BidirectionalStreamFactory<T> extends IBidirectionalStream<T> {
  StreamController<T>? _receiver;
  StreamController<T>? _sender;
  StreamSubscription<T>? _subcription;

  final _complete = Completer();
  final _waitInitialize = Completer();

  bool _isActive = false;
  bool _isInicializer = false;

  BidirectionalStreamFactory();

  factory BidirectionalStreamFactory.initialized({
    required Stream<T> receiver,
    required StreamSink<T> sender,
    required bool closeExternalStreamIfClose,
  }) {
    final item = BidirectionalStreamFactory<T>();
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
    required Stream<T> receiver,
    required StreamSink<T> sender,
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

  void _generateReceive({required Stream<T> receiver}) {
    _receiver = StreamController<T>.broadcast();
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

  void _generateSender({required StreamSink<T> sender, required bool closeExternalStreamIfClose}) {
    _sender = StreamController<T>();
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
  Stream<T> get receiver {
    _checkInicializer();
    _checkActivity();
    return _receiver!.stream;
  }

  @override
  Future get done => _complete.future;

  @override
  bool get isActive => _isActive;

  @override
  void add(T event) {
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
  Future addStream(Stream<T> stream) async {
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

class StreamBidirectionalStandar<T> extends IBidirectionalStream<T> {
  final StreamController<T> _controll;

  const StreamBidirectionalStandar({required StreamController<T> controll}) : _controll = controll;

  factory StreamBidirectionalStandar.broadcast() => StreamBidirectionalStandar(controll: StreamController.broadcast());
  factory StreamBidirectionalStandar.notBroadcast() => StreamBidirectionalStandar(controll: StreamController());

  @override
  void add(T event) => _controll.add(event);

  @override
  void addError(Object error, [StackTrace? stackTrace]) => _controll.addError(error, stackTrace);

  @override
  Future addStream(Stream<T> stream) => _controll.addStream(stream);

  @override
  Future close() => _controll.close();

  @override
  Future get done => _controll.done;

  @override
  Stream<T> get receiver => _controll.stream;

  @override
  bool get isActive => !_controll.isClosed;
}
