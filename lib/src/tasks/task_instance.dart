import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:meta/meta.dart';

enum TaskInstanceStatus { waiting, active, failed, finished }

class TaskInstance<R> with TextableFunctionality<bool>, ITaskFunctionality, IMixableTask {
  static const _pendingText = Oration(message: 'Waiting for the completion of the previous tasks');

  @override
  String get functionalityName => _functionalityName ?? functionality.functionalityName;

  @override
  int identifier;

  final TextableFunctionality<R> functionality;

  final DateTime _whenCreated;
  final String? _functionalityName;

  bool _isActive = false;
  bool _successfullyCompleted = false;
  bool _alreadyExecuted = false;
  bool _canceled = false;
  Oration _lastText = _pendingText;

  R? _lastResult;
  NegativeResult? _lastError;

  MaxiCompleter<bool>? _waiter;
  StreamController<Oration>? _textStream;

  InteractableFunctionalityOperator<Oration, R>? _lastExecutor;

  DateTime _whenLastModification = DateTime.now();
  DateTime _nextTurn = DateTime.fromMillisecondsSinceEpoch(0);

  DateTime get whenLastModification => _whenLastModification;
  DateTime get whenCreated => _whenCreated;
  @override
  DateTime get nextTurn => _nextTurn;

  Oration get lastText => _lastText;
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

  TaskInstanceStatus get status {
    if (isActive) {
      return TaskInstanceStatus.active;
    }

    if (!_alreadyExecuted) {
      return TaskInstanceStatus.waiting;
    }

    return successfullyCompleted ? TaskInstanceStatus.finished : TaskInstanceStatus.failed;
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
    String? functionalityName,
  })  : _whenCreated = whenCreated ?? DateTime.now(),
        _functionalityName = functionalityName ?? functionality.functionalityName;

  void setPending() {
    _lastText = _pendingText;
    _alreadyExecuted = false;
  }

  @override
  Future<bool> runFunctionality({required InteractableFunctionalityExecutor<Oration, bool> manager}) async {
    _isActive = true;
    _lastText = const Oration(message: 'The task is running');

    _whenLastModification = DateTime.now();

    try {
      if (_canceled) {
        throw NegativeResult(identifier: NegativeResultCodes.functionalityCancelled, message: const Oration(message: 'The task was canceled'));
      }

      final newOperator = functionality.createOperator(identifier: identifier);
      _lastExecutor = newOperator;
      final result = await manager.waitFuture(future: newOperator.waitResult(onItem: (item) {
        manager.sendItem(item);
        _textStream?.addIfActive(item);
        _lastText = item;
      }));

      _successfullyCompleted = true;
      _lastResult = result;
    } catch (ex) {
      _lastError = NegativeResult.searchNegativity(item: ex, actionDescription: const Oration(message: 'Execute task'));
      _successfullyCompleted = false;
      _lastText = _lastError!.message;
      _nextTurn = DateTime.now().add(waitToTryAgain);
    } finally {
      _whenLastModification = DateTime.now();
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
      if (otherTask.attempts > attempts) {
        attempts = otherTask.attempts;
      }
    } else {
      (functionality as IMixableTask).mixTask(otherTask);
    }

    _whenLastModification = DateTime.now();
  }
}
