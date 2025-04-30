import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/error_handling/cancel.dart';

class OperatorFunctionalTask<T> with IOperatorFunctionalTask<T> {
  @override
  final int identifier;
  @override
  final bool isPersistent;
  @override
  final Duration waitUntilRetry;
  @override
  final IFunctionalTask<T> task;

  late final IFunctionalController _communicationOperator;

  final _notifyStartTask = StreamController<IOperatorFunctionalTask>.broadcast();
  final _notifyFinishedTask = StreamController<IOperatorFunctionalTask>.broadcast();
  final _notifyCompletedTask = StreamController<T>.broadcast();
  final _notifyFailedTask = StreamController<NegativeResult>.broadcast();
  final _notifyCanceledTask = StreamController<IOperatorFunctionalTask>.broadcast();

  bool _isDisponsed = false;
  late final FutureExpander<bool> _securedFuturesSynchronizer;

  NegativeResult? _lastError;
  T? _lastResult;
  Completer<T>? _waitResult;
  DateTime? _whenFailed;

  FunctionalTaskStates _state = FunctionalTaskStates.awaiting;

  @override
  bool get canRetry {
    return DateTime.now().isAfter(whenFailed.add(waitUntilRetry));
  }

  @override
  Duration get howLongWaitRetry {
    if (canRetry) {
      return Duration.zero;
    }
    return whenFailed.add(waitUntilRetry).difference(DateTime.now());
  }

  @override
  Stream<IOperatorFunctionalTask> get notifyStartTask {
    _checkDisponsed();
    return _notifyStartTask.stream;
  }

  @override
  Stream<IOperatorFunctionalTask> get notifyFinishedTask {
    _checkDisponsed();
    return _notifyFinishedTask.stream;
  }

  @override
  Stream<T> get notifyCompletedTask {
    _checkDisponsed();
    return _notifyCompletedTask.stream;
  }

  @override
  Stream<NegativeResult> get notifyFailedTask {
    _checkDisponsed();
    return _notifyFailedTask.stream;
  }

  @override
  Stream<IOperatorFunctionalTask> get notifyCanceledTask {
    _checkDisponsed();
    return _notifyCanceledTask.stream;
  }

  @override
  NegativeResult get lastError {
    if (_lastError == null) {
      return NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: Oration(message: 'Task %1 never failed', textParts: [identifier]),
      );
    } else {
      return _lastError!;
    }
  }

  @override
  T get lastResult {
    if (_lastResult == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: Oration(message: 'Task %1 was never completed', textParts: [identifier]),
      );
    } else {
      return _lastResult!;
    }
  }

  @override
  DateTime get whenFailed {
    if (_whenFailed == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: Oration(message: 'Task %1 never failed', textParts: [identifier]),
      );
    } else {
      return _whenFailed!;
    }
  }

  @override
  FunctionalTaskStates get state => _state;

  OperatorFunctionalTask({required this.identifier, required this.task, required this.isPersistent, required this.waitUntilRetry}) {
    _communicationOperator = volatile(
      detail: Oration(message: 'The functionality %1 return a communication operator complete (%1 is IFunctionalControllerForOperator and IFunctionalControllerForTask)', textParts: [task.runtimeType]),
      function: () => task.generateCommunicationOperator() as IFunctionalController,
    );

    _securedFuturesSynchronizer = FutureExpander(reservedFunction: _executeAssured);
  }

  void _checkDisponsed() {
    if (_isDisponsed) {
      throw NegativeResult(
        identifier: NegativeResultCodes.statusFunctionalityInvalid,
        message: Oration(message: 'The execution of task %1 cannot be started because it has already finished', textParts: [identifier]),
      );
    }
  }

  @override
  Future<bool> execute() {
    _checkDisponsed();
    return _securedFuturesSynchronizer.execute();
  }

  Future<bool> _executeAssured() async {
    _communicationOperator.reset();
    bool positiveResult = false;
    bool isCancelled = false;

    try {
      _lastResult = await task.executeTask(_communicationOperator);
      positiveResult = true;
      _state = FunctionalTaskStates.finalized;
    } on Cancel catch (ca) {
      if (ca.wantReset) {
        return execute();
      }
      _lastError = NegativeResult(identifier: NegativeResultCodes.functionalityCancelled, message: Oration(message: 'Task %1 was canceled', textParts: [identifier]));
      isCancelled = true;
      _state = FunctionalTaskStates.canceled;
    } on NegativeResult catch (nr) {
      _lastError = nr;
      _state = FunctionalTaskStates.failed;
    } catch (ex) {
      _lastError = NegativeResult.searchNegativity(item: ex, actionDescription: Oration(message: 'Executing functional task No. %1', textParts: [identifier]));
      _state = FunctionalTaskStates.failed;
    }

    _notifyFinishedTask.add(this);
    if (positiveResult) {
      _notifyCompletedTask.add(_lastResult as T);
      _waitResult?.complete(_lastResult!);
      _disponse();
    } else {
      _whenFailed = DateTime.now();
      _notifyFailedTask.add(_lastError!);
      _waitResult?.completeError(_lastError!);
      if (isCancelled) {
        containErrorLogAsync(detail: Oration(message: 'Cancelling task No. %1', textParts: [identifier]), function: () => task.reactCancellation());
      } else {
        containErrorLogAsync(detail: Oration(message: 'Reacting to task failure No. %1', textParts: [identifier]), function: () => task.reactFailure());
      }
      if (isCancelled || !isPersistent) {
        _notifyCanceledTask.add(this);
        _disponse();
      }
    }

    _waitResult = null;

    return positiveResult;
  }

  @override
  void cancel() {
    if (_state == FunctionalTaskStates.canceled) {
      return;
    }

    final isRunning = _state == FunctionalTaskStates.running;
    _lastError = NegativeResult(identifier: NegativeResultCodes.functionalityCancelled, message: Oration(message: 'Task %1 was canceled', textParts: [identifier]));

    if (isRunning) {
      _communicationOperator.cancel();
      containErrorLogAsync(detail: Oration(message: 'Cancelling task #%1', textParts: [identifier]), function: () => task.reactCancellation());
    } else {
      _notifyCanceledTask.add(this);
      _state = FunctionalTaskStates.canceled;
      _notifyFailedTask.add(_lastError!);
      _disponse();
    }
  }

  @override
  Future<T> waitResult() {
    _waitResult ??= MaxiCompleter<T>();

    return _waitResult!.future;
  }

  void _disponse() {
    if (_isDisponsed) {
      return;
    }
    _isDisponsed = true;

    containErrorLogAsync(detail: Oration(message: 'Reacting to task disponse No. %1', textParts: [identifier]), function: () => task.reactDisponse());
    _notifyCanceledTask.close();
    _notifyCompletedTask.close();
    _notifyFailedTask.close();
    _notifyFinishedTask.close();
    _notifyStartTask.close();
  }
}
