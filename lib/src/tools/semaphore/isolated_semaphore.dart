import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tools/internal/shared_values_service.dart';

class IsolatedSemaphore with StartableFunctionality, FunctionalityWithLifeCycle, ISemaphore {
  final String name;
  final Duration defaultDuration;

  final _taskMap = <int, Completer>{};

  IsolatedSemaphore({required this.name, this.defaultDuration = const Duration(seconds: 21)});

  @override
  Future<void> afterInitializingFunctionality() async {
    await SharedValuesService.mountService();

    final event = await ThreadManager.callEntityStream<SharedValuesService, int>(
      parameters: InvocationParameters.only(name),
      function: (serv, para) => serv.getTaskQueue(para.firts<String>()).notifyNextTask,
    );

    joinEvent(event: event, onData: reactToTaskTurn);
  }

  @override
  Future<bool> get checkIfLocker async {
    await initialize();
    return ThreadManager.callEntityFunction<SharedValuesService, bool>(
      parameters: InvocationParameters.only(name),
      function: (serv, para) => serv.getTaskQueue(para.firts<String>()).isActive,
    );
  }

  void reactToTaskTurn(int id) {
    final task = _taskMap.remove(id);
    if (task != null) {
      ThreadManager.callEntityFunction<SharedValuesService, void>(
        parameters: InvocationParameters.list([name, id]),
        function: (serv, para) => serv.getTaskQueue(para.firts<String>()).confirmTaskExecution(para.second<int>()),
      );
      task.completeIfIncomplete();
    }
  }

  Future<int> _createTask(Duration? timeout) async {
    await initialize();

    final id = await ThreadManager.callEntityFunction<SharedValuesService, int>(
      parameters: InvocationParameters.list([name, timeout ?? defaultDuration]),
      function: (serv, para) => serv.getTaskQueue(para.firts<String>()).addReservationTask(para.second<Duration>()),
    );

    final completer = Completer();
    _taskMap[id] = completer;

    await completer.future;

    return id;
  }

  @override
  void afterDiscard() {
    super.afterDiscard();

    _taskMap.entries.iterar(
      (x) => x.value.completeErrorIfIncomplete(
        NegativeResult(
          identifier: NegativeResultCodes.functionalityCancelled,
          message: const Oration(message: 'Isolated semaphore canceled'),
        ),
      ),
    );

    _taskMap.clear();
  }

  void _freeTask(int id) async {
    ThreadManager.callEntityFunction<SharedValuesService, void>(
      parameters: InvocationParameters.list([name, id]),
      function: (serv, para) => serv.getTaskQueue(para.firts<String>()).finishTask(para.second<int>()),
    );
  }

  @override
  Future<T> execute<T>({Duration? timeout, required FutureOr<T> Function() function}) async {
    final id = await _createTask(timeout);

    try {
      return await function();
    } finally {
      _freeTask(id);
    }
  }

  @override
  Future<T?> executeIfStopped<T>({Duration? timeout, required FutureOr<T> Function() function}) async {
    await initialize();
    if (await checkIfLocker) {
      return null;
    } else {
      return execute<T>(function: function, timeout: timeout);
    }
  }

  @override
  Future<T> executeOnlyIsFree<T>({Duration? timeout, required FutureOr<T> Function() function}) async {
    await awaitFullCompletion();
    return await execute(function: function, timeout: timeout);
  }

  @override
  Stream<T> executeStream<T>({Duration? timeout, required Stream<T> stream}) async* {
    final id = await _createTask(timeout);

    bool isDone = false;

    try {
      yield* stream.doOnCancel(() {
        if (!isDone) {
          isDone = true;
          _freeTask(id);
        }
      }).doOnDone(() {
        if (!isDone) {
          isDone = true;
          _freeTask(id);
        }
      });
    } catch (_) {
      _freeTask(id);
      rethrow;
    }
  }

  @override
  Stream<T> executeFutureStream<T>({Duration? timeout, required FutureOr<Stream<T>> Function() function}) async* {
    final id = await _createTask(timeout);

    bool isDone = false;

    try {
      yield* (await function()).doOnCancel(() {
        if (!isDone) {
          isDone = true;
          _freeTask(id);
        }
      }).doOnDone(() {
        if (!isDone) {
          isDone = true;
          _freeTask(id);
        }
      });
    } catch (_) {
      _freeTask(id);
      rethrow;
    }
  }

  @override
  Future<void> awaitFullCompletion() async {
    await initialize();
    while (await checkIfLocker) {
      await execute(function: () {});
      await continueOtherFutures();
    }
  }

  @override
  void cancel() => dispose();
}
