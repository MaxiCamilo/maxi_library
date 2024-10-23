import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class BroadcastPipe<R, S> with StartableFunctionality, IPipe<R, S>, ThreadPipe<R, S> {
  late final List<ThreadPipe<R, S>> _pipeList;
  late final StreamController<R> _receiver;
  late final List<Future> _pendingFutures;
  late final StreamController<ThreadPipe<R, S>> _notifyNewPipe;

  Stream<ThreadPipe<R, S>> get notifyNewPipe => _notifyNewPipe.stream;

  bool _wasClosed = false;

  Completer? _waitingDone;
  final _waitingNewPipesList = <Completer>[];

  @override
  ThreadPipe<R, S> cloner() {
    return BroadcastPipe<R, S>();
  }

  ThreadPipe<R, S> makePipe() {
    checkInitialize();

    final newPipe = ThreadManager.makePipe<R, S>();
    addPipe(pipe: newPipe);

    return newPipe.cloner();
  }

  Future<ThreadPipe<R, S>> makePipeAsync() async {
    await initialize();
    return makePipe();
  }

  @override
  Stream<R> get stream {
    checkInitialize();
    return _receiver.stream;
  }

  @override
  bool get isActive => isInitialized && _pipeList.isNotEmpty;

  void _checkIfClosed() {
    if (_wasClosed) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: tr('Pipe is closed'),
      );
    }
  }

  @override
  void add(S event) {
    checkInitialize();
    _pipeList.iterar((x) => x.add(event));
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    checkInitialize();
    _pipeList.iterar((x) => x.addError(error, stackTrace));
  }

  @override
  Future addStream(Stream<S> stream) async {
    checkInitialize();
    late final StreamSubscription<S> subscription;
    late final Future futureDone;

    subscription = stream.listen(
      add,
      onError: addError,
      onDone: () => futureDone.ignore(),
    );

    futureDone = done.whenComplete(() => subscription.cancel());
  }

  @override
  Future close() async {
    checkInitialize();

    _wasClosed = true;

    _receiver.close();
    _pipeList.iterar((x) => x.close());
    _pipeList.clear();

    _pendingFutures.iterar((x) => x.ignore());
    _pendingFutures.clear();

    if (_waitingDone != null && !_waitingDone!.isCompleted) {
      _waitingDone!.complete();
    }
  }

  @override
  Future get done async {
    checkInitialize();

    if (_wasClosed) {
      return;
    }

    _waitingDone ??= Completer();
    return await _waitingDone!.future;
  }

  @override
  Future<void> initializeFunctionality() async {
    _pipeList = <ThreadPipe<R, S>>[];
    _receiver = StreamController<R>.broadcast();
    _notifyNewPipe = StreamController<ThreadPipe<R, S>>();
    _pendingFutures = <Future>[];
  }

  void addPipe({required ThreadPipe<R, S> pipe}) {
    checkInitialize();
    _checkIfClosed();

    if (!pipe.isInitialized) {
      final future = pipe.initialize();

      _pendingFutures.add(future);

      future.then((_) {
        if (_wasClosed) {
          pipe.close();
        } else {
          addPipe(pipe: pipe);
          _pendingFutures.remove(future);
        }
      });
      return;
    }

    _pipeList.add(pipe);

    pipe.stream.listen((x) => _receiver.add);
    pipe.done.whenComplete(() => _pipeEnd(pipe));

    for (final item in _waitingNewPipesList) {
      item.complete();
    }
    _waitingNewPipesList.clear();
  }

  _pipeEnd(ThreadPipe<R, S> pipe) {
    _pipeList.remove(pipe);
  }

  Future<bool> waitForNewPipes({required Duration? timeout, bool omitIfThereIsPipe = false}) async {
    checkInitialize();

    if (omitIfThereIsPipe && _pipeList.isNotEmpty) {
      return true;
    }

    final waiting = Completer();
    _waitingNewPipesList.add(waiting);

    final future = waiting.future;
    Future? timeoutFuture;

    bool thereIsSomeone = true;

    if (timeout != null) {
      timeoutFuture = Future.delayed(timeout).whenComplete(() {
        if (!waiting.isCompleted) {
          waiting.complete(false);
        }
        _waitingNewPipesList.remove(waiting);
        timeoutFuture = null;
        thereIsSomeone = false;
      });
    }

    await future;
    timeoutFuture?.ignore();
    _waitingNewPipesList.remove(waiting);

    return thereIsSomeone;
  }
}
