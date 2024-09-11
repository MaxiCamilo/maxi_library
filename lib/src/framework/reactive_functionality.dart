import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

mixin IReactiveFunctionality<S, R> implements StreamSink<R> {
  bool get isActive;
  Stream<S> get stream;

  void start();

  IBidirectionalDualStream<S, R> startStreamImmediately();
  BidirectionalDualStreamFactory<S, R> startStreamLater();
}

abstract class ReactiveFunctionalityImplementation<S, R> implements IReactiveFunctionality<S, R> {
  final List<IBidirectionalDualStream<R, S>> _spectators = [];

  bool get closeIfSpectatorsEmptry;

  StreamSubscription<S>? _subcription;
  StreamController<R>? _receiver;
  StreamController<S>? _streamer;

  bool _isActive = false;

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
    if (_isActive) {
      return;
    }

    _receiver = StreamController<R>();
    _streamer = StreamController<S>.broadcast();

    _isActive = true;
  }

  @override
  IBidirectionalDualStream<R, S> startStreamImmediately() {
    //<----- Probablemente hay que poner los bidireccionales alrevez, porque lo que enviamos aca ellos lo reciben
    // TODO: implement startImmediately
    throw UnimplementedError();
  }

  @override
  BidirectionalDualStreamFactory<R, S> startStreamLater() {
    // TODO: implement startLater
    throw UnimplementedError();
  }

  @override
  void add(R event) {
    _checkActive();
    _receiver!.add(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _checkActive();
    _receiver!.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<R> stream) async {
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
  Future close() {
    // TODO: implement close
    throw UnimplementedError();
  }
}
