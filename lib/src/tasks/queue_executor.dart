import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class QueueExecutor<F extends TextableFunctionality> with IDisposable, PaternalFunctionality {
  final int identifier;

  F? _activeFunctionality;
  TextableFunctionalityOperator? _activeOperator;

  StreamController<(F, Oration)>? _textStream;

  late StreamController<F> _changedExecutionTask;
  late StreamController<F> _activeTaskEnded;

  late StreamController<QueueExecutor<F>> _executorIsActivated;
  late StreamController<QueueExecutor<F>> _executorIsInactivated;
  late StreamController<F> _taskChangedState;

  final _pendingFunctionalities = <F>[];
  final _persistentFunctionalities = <F>[];

  F? get activeFunctionality => _activeFunctionality;
  List<F> get pendingFunctionalities => _pendingFunctionalities;
  List<F> get persistentFunctionalities => _persistentFunctionalities;

  List<F> get tasks {
    final list = <F>[..._pendingFunctionalities, ..._persistentFunctionalities];

    if (_activeFunctionality != null) {
      list.insert(0, _activeFunctionality!);
    }

    return list;
  }

  bool _isActive = false;
  F? _nextPersistent;

  Timer? _timerNext;
  MaxiCompleter? _timerWaiter;

  Stream<F> get changedExecutionTask => _changedExecutionTask.stream;
  Stream<F> get activeTaskEnded => _activeTaskEnded.stream;
  Stream<QueueExecutor<F>> get executorIsActivated => _executorIsActivated.stream;
  Stream<QueueExecutor<F>> get executorIsInactivated => _executorIsInactivated.stream;
  Stream<F> get taskChangedState => _taskChangedState.stream;

  bool get isActive => _isActive;

  Stream<(F, Oration)> get textStream async* {
    _textStream ??= StreamController<(F, Oration)>.broadcast();
    yield* _textStream!.stream;
  }

  QueueExecutor({this.identifier = 0}) {
    performResurrection();
  }

  @override
  void performResurrection() {
    super.performResurrection();

    _changedExecutionTask = createEventController<F>(isBroadcast: true);
    _activeTaskEnded = createEventController<F>(isBroadcast: true);

    _executorIsActivated = createEventController<QueueExecutor<F>>(isBroadcast: true);
    _executorIsInactivated = createEventController<QueueExecutor<F>>(isBroadcast: true);
    _taskChangedState = createEventController<F>(isBroadcast: true);
  }

  @override
  void performObjectDiscard() {
    super.performObjectDiscard();

    cancelAll();
    _activeFunctionality = null;

    _activeOperator?.dispose();
    _activeOperator = null;

    _textStream?.close();
    _textStream = null;

    _timerWaiter?.completeIfIncomplete();
    _timerWaiter = null;
  }

  void cancelAll() {
    _pendingFunctionalities.whereType<IDisposable>().iterar((x) => x.dispose());
    _persistentFunctionalities.whereType<IDisposable>().iterar((x) => x.dispose());

    _pendingFunctionalities.whereType<TaskInstance>().iterar((x) => x.cancel());
    _persistentFunctionalities.whereType<TaskInstance>().iterar((x) => x.cancel());

    _pendingFunctionalities.clear();
    _persistentFunctionalities.clear();

    if (_activeFunctionality != null && _activeFunctionality is TaskInstance) {
      (_activeFunctionality as TaskInstance).cancel();
    }

    if (_activeFunctionality != null && _activeFunctionality is IDisposable) {
      (_activeFunctionality as IDisposable).dispose();
    }

    _activeOperator?.cancel();
  }

  F? searchTask(int identifier) {
    if (_activeFunctionality != null && _activeOperator != null && _activeOperator!.identifier == identifier) {
      return _activeFunctionality;
    }

    final isPending = _pendingFunctionalities.whereType<ITaskFunctionality>().selectItem((x) => x.identifier == identifier);
    if (isPending != null) {
      return isPending as F;
    }

    final isPersistent = _persistentFunctionalities.whereType<ITaskFunctionality>().selectItem((x) => x.identifier == identifier);
    if (isPersistent != null) {
      return isPersistent as F;
    }

    return null;
  }

  void cancelActiveFunctionality() {
    _activeOperator?.cancel();
  }

  bool cancelTask(int identifier) {
    if (_activeOperator != null && _activeOperator!.identifier == identifier) {
      cancelActiveFunctionality();
      return true;
    }

    final persistent = _persistentFunctionalities.whereType<TaskInstance>().selectItem((x) => x.identifier == identifier);
    if (persistent != null) {
      persistent.cancel();
      _persistentFunctionalities.remove(persistent);
      _timerWaiter?.completeIfIncomplete();
      _timerWaiter = null;
      _taskChangedState.addIfActive(persistent as F);
      return true;
    }

    final pending = _pendingFunctionalities.whereType<TaskInstance>().selectItem((x) => x.identifier == identifier);
    if (pending != null) {
      pending.cancel();
      _pendingFunctionalities.remove(pending);
      _taskChangedState.addIfActive(pending as F);
      return true;
    }

    return false;
  }

  bool startTask(int identifier) {
    if (_activeOperator != null && _activeOperator!.identifier == identifier) {
      return true;
    }

    final isPending = _pendingFunctionalities.whereType<ITaskFunctionality>().selectItem((x) => x.identifier == identifier);
    if (isPending != null) {
      return true;
    }

    final isPersistent = _persistentFunctionalities.whereType<ITaskFunctionality>().selectItem((x) => x.identifier == identifier);
    if (isPersistent != null) {
      _persistentFunctionalities.remove(isPersistent);
      _pendingFunctionalities.add(isPersistent as F);
      _timerWaiter?.completeIfIncomplete();

      return true;
    }

    return false;
  }

  F addFunctionality({required F newTask, bool mixTask = true}) {
    resurrectObject();
    if (mixTask) {
      if (_activeFunctionality != null && _activeFunctionality is IMixableTask && (_activeFunctionality as IMixableTask).isMixable(newTask)) {
        (_activeFunctionality! as IMixableTask).mixTask(newTask);
        return _activeFunctionality!;
      }

      final pendingCandidate = _pendingFunctionalities.whereType<IMixableTask>().selectItem((x) => x.isMixable(newTask));
      if (pendingCandidate != null) {
        pendingCandidate.mixTask(newTask);
        _timerWaiter?.completeIfIncomplete();
        return pendingCandidate as F;
      }

      final persistentCandidate = _persistentFunctionalities.whereType<IMixableTask>().selectItem((x) => x.isMixable(newTask));
      if (persistentCandidate != null) {
        persistentCandidate.mixTask(newTask);

        _persistentFunctionalities.remove(persistentCandidate);
        _pendingFunctionalities.add(persistentCandidate as F);
        if (_nextPersistent == persistentCandidate) {
          _timerWaiter?.completeIfIncomplete();
        }

        return persistentCandidate as F;
      }
    }

    _pendingFunctionalities.add(newTask);

    if (newTask is TaskInstance) {
      newTask.setPending();
    }

    _taskChangedState.addIfActive(newTask);

    if (!_isActive) {
      _isActive = true;
      maxiScheduleMicrotask(_runFunctionalities);
    } else {
      _timerWaiter?.completeIfIncomplete();
    }

    return newTask;
  }

  Future<void> _runFunctionalities() async {
    _isActive = true;
    _executorIsActivated.add(this);

    do {
      while (_pendingFunctionalities.isNotEmpty) {
        await _executeTask(_pendingFunctionalities.removeAt(0));
      }

      _addPersistentToPending();

      if (_pendingFunctionalities.isEmpty) {
        await _checkPersistents();
      }
    } while (_pendingFunctionalities.isNotEmpty);
    _activeFunctionality = null;

    _isActive = false;
    _executorIsInactivated.add(this);
  }

  Future<void> _executeTask(F actual) async {
    _activeFunctionality = actual;

    _taskChangedState.addIfActive(actual);

    if (actual is TaskInstance) {
      final actualOperator = actual.createOperator(identifier: actual.identifier);
      _activeOperator = actualOperator;
      late final bool isGood;
      try {
        scheduleMicrotask(() async {
          await continueOtherFutures();
          await continueOtherFutures();
          await continueOtherFutures();
          _taskChangedState.addIfActive(actual);
        });
        isGood = await actualOperator.waitResult(
          onItem: (item) => _textStream?.addIfActive((actual, item)),
        );
      } catch (_) {
        isGood = false;
      }

      if (!isGood && actual.itIsPersistent) {
        actual.attempts = actual.attempts - 1;
        _persistentFunctionalities.add(actual);
      }
    } else {
      final actualOperator = actual.createOperator();
      try {
        await actualOperator.waitResult(
          onItem: (item) => _textStream?.addIfActive((actual, item)),
        );
      } catch (_) {
        if (actual is ITaskFunctionality && (actual as ITaskFunctionality).itIsPersistent && (actual as ITaskFunctionality).attempts > 0) {
          (actual as ITaskFunctionality).attempts = (actual as ITaskFunctionality).attempts - 1;
          _persistentFunctionalities.add(actual);
        }
      }
    }

    _activeTaskEnded.addIfActive(actual);
    _taskChangedState.addIfActive(actual);
    _activeOperator = null;
  }

  void _addPersistentToPending() {
    final reintent = _persistentFunctionalities.cast<ITaskFunctionality>().where((x) => DateTime.now().isBefore(x.nextTurn)).toList();

    for (final item in reintent) {
      _persistentFunctionalities.remove(item);
      _pendingFunctionalities.add(item as F);

      if (item is TaskInstance) {
        item.setPending();
      }

      _taskChangedState.addIfActive(item as F);
    }
  }

  Future<void> _checkPersistents() async {
    if (_persistentFunctionalities.isEmpty) {
      return;
    }

    final persistents = _persistentFunctionalities.cast<ITaskFunctionality>();
    if (persistents.isEmpty) {
      return;
    }

    final earliestTask = persistents.minimumOf((x) => x.waitToTryAgain.inMilliseconds);
    _nextPersistent = earliestTask as F;

    _timerWaiter = MaxiCompleter();
    _timerNext = Timer(earliestTask.waitToTryAgain, () {
      _timerWaiter?.completeIfIncomplete();
    });

    await _timerWaiter!.future;

    _timerNext?.cancel();
    _timerWaiter?.completeIfIncomplete();
    _timerNext = null;
    _timerWaiter = null;
    _nextPersistent = null;

    _addPersistentToPending();
  }
}
