import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';

class StreamPipe<R, S> with IPipe<R, S> {
  final StreamSink<S> sink;
  final bool closeIfCloneIsClosed;

  final _receiver = StreamController<R>.broadcast();
  final _done = Completer();

  late final StreamSubscription<R> _subscription;

  bool _isActive = true;

  @override
  Stream<R> get stream => _receiver.stream;

  @override
  Future get done => _done.future;

  @override
  bool get isActive => _isActive;

  StreamPipe({required this.sink, required this.closeIfCloneIsClosed, required Stream<R> receiver}) {
    _subscription = receiver.listen(
      (event) => _receiver.add(event),
      onError: (x, y) => _receiver.addError(x, y),
      onDone: () => close(),
    );

    sink.done.whenComplete(() => close());
  }


  factory StreamPipe.fromOtherPipe({required IPipe<R, S> pipe, required bool closeIfCloneIsClosed}) {
    return StreamPipe<R, S>(receiver: pipe.stream, sink: pipe, closeIfCloneIsClosed: closeIfCloneIsClosed);
  }

  

  @override
  Future close() async {
    if (!_isActive) {
      return;
    }

    _isActive = false;
    _done.completeIfIncomplete();
    _subscription.cancel();
    if (closeIfCloneIsClosed) {
      sink.close();
    }
  }

  @override
  void add(S event) {
    if (isActive) {
      sink.add(event);
    } else {
      log('[StreamPipe] The pipe is closed');
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    if (isActive) {
      sink.addError(error, stackTrace);
    } else {
      log('[StreamPipe] The pipe is closed');
    }
  }

  @override
  Future addStream(Stream<S> stream) async {
    if (!isActive) {
      log('[StreamPipe] The pipe is closed');
      return;
    }

    final compelteter = Completer();

    final subscription = stream.listen(
      (x) => add(x),
      onError: (x, y) => addError(x, y),
      onDone: () => compelteter.completeIfIncomplete(),
    );

    final future = done.whenComplete(() => compelteter.completeIfIncomplete());

    await compelteter.future;

    subscription.cancel();
    future.ignore();
  }
}
