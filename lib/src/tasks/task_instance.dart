import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tasks/imixable_task.dart';
import 'package:maxi_library/src/tasks/itask_functionality.dart';
import 'package:meta/meta.dart';

enum TagInstanceStatus { waiting, active, failed, finished }

class TaskInstance<R> with TextableFunctionality<bool>, ITaskFunctionality, IMixableTask {
  int identifier;

  final TextableFunctionality<R> functionality;

  final DateTime _whenCreated;

  bool _isActive = false;
  bool _successfullyCompleted = false;
  bool _alreadyExecuted = false;
  bool _canceled = false;
  R? _lastResult;
  NegativeResult? _lastError;

  MaxiCompleter<bool>? _waiter;
  StreamController<Oration>? _textStream;

  InteractableFunctionalityOperator<Oration, R>? _lastExecutor;

  DateTime _whenFinished = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _nextTurn = DateTime.fromMillisecondsSinceEpoch(0);

  DateTime get whenFinished => _whenFinished;
  DateTime get whenCreated => _whenCreated;
  @override
  DateTime get nextTurn => _nextTurn;

  bool get isActive => _isActive;
  bool get successfullyCompleted => _successfullyCompleted;
  bool get alreadyExecuted => _alreadyExecuted;

  @override
  bool get itIsPersistent => !_canceled && attempts > 0;

  @override
  int attempts;

  @override
  Duration waitToTryAgain;

  NegativeResult get lastError {
    return _lastError ??
        NegativeResult(
          identifier: NegativeResultCodes.contextInvalidFunctionality,
          message: const Oration(message: 'The task did not start'),
        );
  }

  R get lastResult {
    if (!alreadyExecuted || !successfullyCompleted) {
      throw lastError;
    }

    return _lastResult as R;
  }

  TagInstanceStatus get status {
    if (!_alreadyExecuted) {
      return TagInstanceStatus.waiting;
    }

    if (isActive) {
      return TagInstanceStatus.active;
    }

    return successfullyCompleted ? TagInstanceStatus.finished : TagInstanceStatus.failed;
  }

  Stream<Oration> get textStream async* {
    if (_canceled || _successfullyCompleted) {
      return;
    }

    _textStream = StreamController<Oration>.broadcast();
    yield* _textStream!.stream;
  }

  TaskInstance({
    required this.functionality,
    this.identifier = 0,
    this.waitToTryAgain = const Duration(minutes: 5),
    this.attempts = 0,
    DateTime? whenCreated,
  }) : _whenCreated = whenCreated ?? DateTime.now();

  @override
  Future<bool> runFunctionality({required InteractableFunctionalityExecutor<Oration, bool> manager}) async {
    _isActive = true;

    try {
      if (_canceled) {
        throw NegativeResult(identifier: NegativeResultCodes.functionalityCancelled, message: const Oration(message: 'The task was canceled'));
      }

      final newOperator = functionality.createOperator(identifier: identifier);
      _lastExecutor = newOperator;
      final result = await manager.waitFuture(future: newOperator.waitResult(onItem: (item) {
        manager.sendItem(item);
        _textStream?.addIfActive(item);
      }));

      _successfullyCompleted = true;
      _lastResult = result;
    } catch (ex) {
      _lastError = NegativeResult.searchNegativity(item: ex, actionDescription: const Oration(message: 'Execute task'));
      _successfullyCompleted = false;
      _nextTurn = DateTime.now().add(waitToTryAgain);
    } finally {
      _whenFinished = DateTime.now();
      _alreadyExecuted = true;
      _isActive = false;

      _lastExecutor?.dispose();
      _lastExecutor = null;

      _textStream?.close();
      _textStream = null;
    }

    _waiter?.completeIfIncomplete(_successfullyCompleted);
    _waiter = null;

    return _successfullyCompleted;
  }

  void cancel() {
    if (_canceled) {
      return;
    }

    _canceled = true;

    _lastExecutor?.cancel();

    _lastError = NegativeResult(identifier: NegativeResultCodes.functionalityCancelled, message: const Oration(message: 'The task was canceled'));
    _successfullyCompleted = false;
    _alreadyExecuted = true;

    _waiter?.completeIfIncomplete(false);
    _waiter = null;
  }

  MaxiFuture<bool> waitResult({void Function(Oration item)? onItem}) {
    _waiter ??= MaxiCompleter<bool>(waiterName: 'Task N° $identifier');

    if (_successfullyCompleted) {
      scheduleMicrotask(() {
        _waiter?.completeIfIncomplete(true);
        _waiter = null;
      });
    }

    if (!_successfullyCompleted && onItem != null) {
      textStream.listen(onItem);
    }

    return _waiter!.future;
  }

  @override
  void onCancel({required InteractableFunctionalityExecutor<Oration, bool> manager}) {
    super.onCancel(manager: manager);
    _lastExecutor?.cancel();
  }

  @override
  @protected
  void onManagerDispose() {
    super.onManagerDispose();
    _lastExecutor?.dispose();
    _textStream?.close();
  }

  @protected
  @override
  void onThereAreNoListeners({required InteractableFunctionalityExecutor<Oration, bool> manager}) {
    super.onThereAreNoListeners(manager: manager);
    if (_isActive && _lastExecutor != null) {
      functionality.onThereAreNoListeners(manager: _lastExecutor! as InteractableFunctionalityExecutor<Oration, R>);
    }
  }

  @override
  bool isMixable(TextableFunctionality otherTask) {
    if (_canceled) {
      return false;
    }

    if (functionality is IMixableTask) {
      if (otherTask is TaskInstance) {
        return (functionality as IMixableTask).isMixable(otherTask.functionality);
      } else {
        return (functionality as IMixableTask).isMixable(otherTask);
      }
    } else {
      return false;
    }
  }

  @override
  void mixTask(TextableFunctionality otherTask) {
    if (functionality is! IMixableTask) {
      return;
    }

    if (otherTask is TaskInstance) {
      (functionality as IMixableTask).mixTask(otherTask.functionality);
    } else {
      (functionality as IMixableTask).mixTask(otherTask);
    }
  }
}
