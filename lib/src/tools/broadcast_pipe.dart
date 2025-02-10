import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class BroadcastPipe<R, S> with IPipe<R, S> {
  final bool closeIfNoOneListens;
  final bool closeConnectedPipesIfFinished;

  final _otherPipes = <IPipe<R, S>>[];
  final _receiver = StreamController<R>.broadcast();
  final _doDone = Completer<BroadcastPipe<R, S>>();
  Completer<IPipe<R, S>?>? _waitingNewPipe;

  bool _isActive = true;

  @override
  Stream<R> get stream => _receiver.stream;

  @override
  bool get isActive => _isActive;

  BroadcastPipe({required this.closeIfNoOneListens, required this.closeConnectedPipesIfFinished});

  void connectPipe(IPipe<R, S> pipe) {
    checkProgrammingFailure(thatChecks: Oration(message: 'Brodcast pipe is close'), result: () => _isActive);
    pipe.stream.listen(
      _receiver.add,
      onError: _receiver.addError,
    );

    pipe.done.whenComplete(() => _reactPipeClose(pipe));
    _otherPipes.add(pipe);
  }

  void joinStream(Stream<R> receive) {
    final compelteter = Completer();

    final subscription = stream.listen(
      _receiver.add,
      onError: _receiver.addError,
      onDone: () => compelteter.completeIfIncomplete(),
    );

    Future.any([compelteter.future, done]).whenComplete(() {
      subscription.cancel();
      compelteter.completeIfIncomplete();
    });
  }

  void _reactPipeClose(IPipe<R, S> pipe) {
    _otherPipes.remove(pipe);
    if (closeIfNoOneListens && _otherPipes.isEmpty) {
      close();
    }
  }

  @override
  void add(S event) {
    checkProgrammingFailure(thatChecks: Oration(message: 'Brodcast pipe is close'), result: () => _isActive);

    for (final pipe in _otherPipes) {
      pipe.add(event);
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    checkProgrammingFailure(thatChecks: Oration(message: 'Brodcast pipe is close'), result: () => _isActive);
    for (final pipe in _otherPipes) {
      pipe.addError(error, stackTrace);
    }
  }

  @override
  Future addStream(Stream<S> stream) async {
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

  @override
  Future get done => _doDone.future;

  @override
  Future close() async {
    if (!_isActive) {
      return;
    }

    _isActive = false;
    _receiver.close();

    if (closeConnectedPipesIfFinished) {
      _otherPipes.iterar((x) => x.close());
    }

    _otherPipes.clear();
    _doDone.completeIfIncomplete(this);
  }

  Future<IPipe<R, S>?> waitForNewPipes({required Duration? timeout, bool omitIfThereIsPipe = false}) async {
    if (omitIfThereIsPipe && _otherPipes.isNotEmpty) {
      return null;
    }

    _waitingNewPipe ??= Completer<IPipe<R, S>?>();

    Future? timeoutWaiter;

    if (timeout != null) {
      timeoutWaiter = Future.delayed(timeout).whenComplete(() {
        _waitingNewPipe?.completeIfIncomplete(null);
      });
    }

    final result = await _waitingNewPipe!.future;
    _waitingNewPipe = null;
    timeoutWaiter?.ignore();

    return result;
  }
}
