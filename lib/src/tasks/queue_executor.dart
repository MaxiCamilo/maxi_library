import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tasks/imixable_task.dart';
import 'package:maxi_library/src/tasks/itask_functionality.dart';
import 'package:maxi_library/src/tasks/task_instance.dart';

class QueueExecutor<F extends TextableFunctionality> with IDisposable, PaternalFunctionality {
  F? _activeFunctionality;
  TextableFunctionalityOperator? _activeOperator;

  StreamController<Oration>? _textStream;

  final _pendingFunctionalities = <F>[];
  final _persistentFunctionalities = <F>[];

  F? get activeFunctionality => _activeFunctionality;
  List<F> get pendingFunctionalities => _pendingFunctionalities;
  List<F> get persistentFunctionalities => _persistentFunctionalities;

  bool _isActive = false;
  F? _nextPersistent;

  Timer? _timerNext;
  MaxiCompleter? _timerWaiter;

  Stream<Oration> get textStream async* {
    _textStream ??= StreamController<Oration>.broadcast();
    yield* _textStream!.stream;
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

  void cancel(int identifier) {
    if (_activeOperator != null && _activeOperator!.identifier == identifier) {
      _activeOperator?.cancel();
      return;
    }

    final persistent = _persistentFunctionalities.whereType<TaskInstance>().selectItem((x) => x.identifier == identifier);
    if (persistent != null) {
      persistent.cancel();
      _persistentFunctionalities.remove(persistent);
      _timerWaiter?.completeIfIncomplete();
      _timerWaiter = null;
      return;
    }

    final pending = _pendingFunctionalities.whereType<TaskInstance>().selectItem((x) => x.identifier == identifier);
    if (pending != null) {
      pending.cancel();
      _pendingFunctionalities.remove(pending);
      return;
    }
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
      }
    }

    _pendingFunctionalities.add(newTask);

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
  }

  Future<void> _executeTask(F actual) async {
    _activeFunctionality = actual;
    if (actual is TaskInstance) {
      final actualOperator = actual.createOperator(identifier: actual.identifier);
      _activeOperator = actualOperator;
      late final bool isGood;
      try {
        isGood = await actualOperator.waitResult(
          onItem: (item) => _textStream?.addIfActive(item),
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
          onItem: (item) => _textStream?.addIfActive(item),
        );
      } catch (_) {
        if (actual is ITaskFunctionality && (actual as ITaskFunctionality).itIsPersistent && (actual as ITaskFunctionality).attempts > 0) {
          (actual as ITaskFunctionality).attempts = (actual as ITaskFunctionality).attempts - 1;
          _persistentFunctionalities.add(actual);
        }
      }
    }

    _activeOperator = null;
  }

  void _addPersistentToPending() {
    final reintent = _persistentFunctionalities.cast<ITaskFunctionality>().where((x) => DateTime.now().isBefore(x.nextTurn)).toList();

    for (final item in reintent) {
      _persistentFunctionalities.remove(item);
      _pendingFunctionalities.add(item as F);
    }
  }

  Future<void> _checkPersistents() async {
    if (_persistentFunctionalities.isNotEmpty) {
      return;
    }

    final persistents = _persistentFunctionalities.cast<ITaskFunctionality>();
    if (persistents.isNotEmpty) {
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
