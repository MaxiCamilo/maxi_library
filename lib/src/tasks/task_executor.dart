import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tasks/interfaces/itask_executor.dart';

class TaskExecutor with ITaskExecutor {
  @override
  IOperatorFunctionalTask? activeTask;

  @override
  final pendingTasks = <IOperatorFunctionalTask>[];

  @override
  final persistentTasks = <IOperatorFunctionalTask>[];

  bool _active = false;
  int _lastId = 1;

  @override
  void cancelAll() {
    final copyPersistentTasks = persistentTasks.toList();
    final copyPendingTasks = pendingTasks.toList();

    pendingTasks.clear();
    persistentTasks.clear();

    copyPersistentTasks.iterar((x) => x.cancel());
    copyPendingTasks.iterar((x) => x.cancel());

    activeTask?.cancel();
    activeTask = null;
  }

  @override
  IOperatorFunctionalTask<T> generateTask<T>({
    required IFunctionalTask<T> functionality,
    required bool isPersistent,
    required Duration waitUntilRetry,
    required bool isMixable,
  }) {
    if (isMixable) {
      final exists = _searchMixableTask<T>(functionality);
      if (exists != null) {
        (exists.task as IFunctionalTaskMixable).mixTask(functionality);
        return exists;
      }
    }

    return _generateNewTask<T>(functionality: functionality, isPersistent: isPersistent, waitUntilRetry: waitUntilRetry);
  }

  IOperatorFunctionalTask<T> _generateNewTask<T>({
    required IFunctionalTask<T> functionality,
    required bool isPersistent,
    required Duration waitUntilRetry,
  }) {
    final newOperator = OperatorFunctionalTask<T>(
      identifier: _lastId,
      isPersistent: isPersistent,
      task: functionality,
      waitUntilRetry: waitUntilRetry,
    );

    _lastId += 1;
    pendingTasks.add(newOperator);

    _initExecutor();
    return newOperator;
  }

  IOperatorFunctionalTask<T>? _searchMixableTask<T>(IFunctionalTask functionality) {
    if (activeTask != null && isCompatible<T>(activeTask!, functionality)) {
      return activeTask as IOperatorFunctionalTask<T>;
    }

    for (final item in pendingTasks) {
      if (isCompatible<T>(item, functionality)) {
        return item as IOperatorFunctionalTask<T>;
      }
    }

    for (final item in persistentTasks) {
      if (isCompatible<T>(item, functionality)) {
        final persistent = item as IOperatorFunctionalTask<T>;
        persistentTasks.remove(persistent);
        pendingTasks.add(persistent);
        _initExecutor();
        return persistent;
      }
    }

    return null;
  }

  bool isCompatible<T>(IOperatorFunctionalTask operatorTask, IFunctionalTask functionality) {
    if (operatorTask is! IOperatorFunctionalTask<T>) {
      return false;
    }

    final task = operatorTask.task;
    if (task is! IFunctionalTaskMixable) {
      return false;
    }

    return (task as IFunctionalTaskMixable).isCompatible(functionality);
  }

  void _initExecutor() {
    if (_active) {
      return;
    }
    _active = true;

    scheduleMicrotask(_executePendingTasks);
  }

  Future<void> _executePendingTasks() async {
    _active = true;

    while (pendingTasks.isNotEmpty) {
      final first = pendingTasks.removeAt(0);
      activeTask = first;

      final isCorrect = await first.execute();
      if (!isCorrect && first.isPersistent) {
        scheduleMicrotask(() => _waitFailedTaskToResume(first));
      }
    }

    activeTask = null;
    _active = false;
  }

  Future<void> _waitFailedTaskToResume(IOperatorFunctionalTask task) async {
    persistentTasks.add(task);

    final career = FutureCareer(closedChannelDoes: ClosedChannelDoes.interrupts);
    career.linkStream(task.notifyStartTask);
    career.linkStream(task.notifyCanceledTask);
    career.setTimeout(duration: task.howLongWaitRetry);

    await containErrorLogAsync(detail: () => trc('waiting for task retry N° %1', [task.identifier]), function: () => career.waitOptionalItem());
    persistentTasks.remove(task);

    if (task.state == FunctionalTaskStates.failed || task.state == FunctionalTaskStates.awaiting) {
      if (!pendingTasks.contains(task)) {
        pendingTasks.add(task);
      }

      _initExecutor();
    }
  }
}
