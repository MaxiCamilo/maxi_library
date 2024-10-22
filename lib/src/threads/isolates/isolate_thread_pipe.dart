import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/isolates/isolate_thread_pipe_processor.dart';
import 'package:maxi_library/src/threads/ithread_invoke_instance.dart';

class IsolateThreadPipe<R, S> with StartableFunctionality, IPipe<R, S> ,ThreadPipe<R, S> {
  final int identifier;

  late final int externalID;

  late final int creatorThreadId;
  late final IThreadInvokeInstance connection;
  late final StreamController<R> receiver;
  late final Completer waitingDone;
  late final bool isExternalPipe;

  bool _isActive = false;
  bool _isDisnponse = false;

  Completer? _waitingConfirmation;

  bool get inCreatorThread => creatorThreadId == ThreadManager.instance.threadID;

  @override
  Future get done {
    checkInitialize();
    return waitingDone.future;
  }

  @override
  bool get isActive => _isActive;

  @override
  Stream<R> get stream {
    checkInitialize();
    return receiver.stream;
  }

  IsolateThreadPipe({required this.identifier}) {
    creatorThreadId = ThreadManager.instance.threadID;
  }

  @override
  ThreadPipe<R, S> cloner() {
    return IsolateThreadPipe<R, S>(identifier: identifier);
  }

  void _checkActivity() {
    if (!_isActive) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: tr('Pipe is closed'),
      );
    }
  }

  @override
  Future<void> initializeFunctionality() async {
    if (inCreatorThread) {
      isExternalPipe = false;
      _waitingConfirmation ??= Completer();
      await _waitingConfirmation!.future;
      _defineObjects();
      return;
    }

    isExternalPipe = true;
    connection = await ThreadManager.instance.locateConnection(creatorThreadId);
    externalID = (ThreadManager.instance.pipeProcessor as IsolateThreadPipeProcessor).addExternalPipe(pipe: this);

    await connection.callFunctionAsAnonymous(
      parameters: InvocationParameters.list([identifier, ThreadManager.instance.threadID, externalID]),
      function: (para) async => para.thread.pipeProcessor.confirmStarted(
        streamID: para.firts<int>(),
        threadID: para.second<int>(),
        externID: para.third<int>(),
      ),
    );

    _defineObjects();
  }

  void confirmStarted({required IThreadInvokeInstance connection, required int externalID}) {
    this.connection = connection;
    this.externalID = externalID;
    if (_waitingConfirmation != null && !_waitingConfirmation!.isCompleted) {
      _waitingConfirmation!.complete();
    }
  }

  void _defineObjects() {
    receiver = StreamController<R>.broadcast();
    waitingDone = Completer();
    _isActive = true;
  }

  @override
  void add(S event) {
    checkInitialize();
    _checkActivity();

    connection.callFunctionAsAnonymous(
      parameters: InvocationParameters.list([isExternalPipe ? identifier : externalID, event, !isExternalPipe]),
      function: (x) async => x.thread.pipeProcessor.notifyNewItem(
        streamID: x.firts<int>(),
        item: x.second(),
        isExternalPipe: x.third<bool>(),
      ),
    );
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    checkInitialize();
    _checkActivity();

    connection.callFunctionAsAnonymous(
      parameters: InvocationParameters.list([isExternalPipe ? identifier : externalID, error, stackTrace, !isExternalPipe]),
      function: (x) async => x.thread.pipeProcessor.notifyNewError(
        streamID: x.firts<int>(),
        error: x.second(),
        stackTrace: x.third(),
        isExternalPipe: x.fourth<bool>(),
      ),
    );
  }

  @override
  Future addStream(Stream<S> stream) async {
    checkInitialize();
    _checkActivity();

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
    if (_waitingConfirmation != null && !_waitingConfirmation!.isCompleted) {
      _waitingConfirmation!.completeError(NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: tr('Stream was closed'),
      ));
    }

    if (!_isActive) {
      return;
    }

    defineClosed();
    await connection.callFunctionAsAnonymous(
      parameters: InvocationParameters.list([isExternalPipe ? identifier : externalID, !isExternalPipe]),
      function: (x) async => x.thread.pipeProcessor.notifyPipeClosure(streamID: x.firts<int>(), isExternalPipe: x.second<bool>()),
    );
  }

  void defineClosed() {
    if (_isDisnponse) {
      return;
    }
    _isDisnponse = true;
    _isActive = false;
    receiver.close();
    if (_waitingConfirmation != null && !_waitingConfirmation!.isCompleted) {
      _waitingConfirmation!.completeError(NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: tr('Stream was closed'),
      ));
    }

    if (!waitingDone.isCompleted) {
      waitingDone.complete();
    }

    ThreadManager.instance.pipeProcessor.removePipe(streamID: isExternalPipe ? externalID : identifier, isExternalPipe: isExternalPipe);
  }

  void receiveData(dynamic item) {
    if (item is R) {
      receiver.add(item);
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: tr('The stream does not accept items %1, it only accepts %2', [item.runtimeType, R]),
      );
    }
  }
}
