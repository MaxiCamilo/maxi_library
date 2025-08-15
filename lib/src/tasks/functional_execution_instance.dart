import 'dart:async';

import 'package:maxi_library/export_reflectors.dart';

typedef TextableFunctionalExecutionInstance<R> = FunctionalExecutionInstance<Oration, R>;
typedef TextableFunctionalExecutionInstanceVoid = FunctionalExecutionInstance<Oration, void>;

class FunctionalExecutionInstance<I, R> with IDisposable, PaternalFunctionality, InteractiveFunctionalityOperator<I, R> {
  @override
  final int identifier;

  final InteractiveFunctionality<I, R> _functionality;

  InteractiveFunctionalityOperator<I, R>? _executor;

  late MaxiCompleter<R> _waiter;

  bool _isActive = false;
  bool _successfullyCompleted = false;
  bool _alreadyExecuted = false;

  R? _lastResult;
  NegativeResult? _lastError;

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

  bool get isActive => _isActive;
  bool get successfullyCompleted => _successfullyCompleted;
  bool get alreadyExecuted => _alreadyExecuted;

  late StreamController<I> _itemStreamController;

  @override
  Stream<I> get itemStream async* {
    checkIfDispose();

    yield* _itemStreamController.stream;
  }

  FunctionalExecutionInstance({required InteractiveFunctionality<I, R> functionality, this.identifier = 0}) : _functionality = functionality {
    performResurrection();
  }

  @override
  void performResurrection() {
    _isActive = false;

    _itemStreamController = createEventController<I>(isBroadcast: true);
  }

  @override
  void performObjectDiscard() {
    super.performObjectDiscard();
    _isActive = false;
  }

  @override
  void cancel() {
    _executor?.dispose();
  }

  void reset() {
    if (wasDiscarded) {
      resurrectObject();
    }

    if (isActive) {
      _executor!.onDispose.whenComplete(() {
        start();
      });
      _executor!.dispose();
    } else {
      start();
    }
  }

  Future<R> executeIfNotAlreadyRunning({void Function(I item)? onItem}) async {
    if (_alreadyExecuted) {
      if (_successfullyCompleted) {
        return lastResult;
      } else {
        throw lastError;
      }
    }

    return await waitResult(onItem: onItem);
  }

  @override
  MaxiFuture<R> waitResult({void Function(I item)? onItem}) {
    if (_isActive) {
      start();
    }

    if (onItem != null) {
      _executor!.itemStream.listen((x) => onItem(x));
    }

    return _waiter.future;
  }

  @override
  void start() {
    if (wasDiscarded) {
      resurrectObject();
    }

    if (_isActive) {
      return;
    }

    _alreadyExecuted = true;
    _isActive = true;

    _executor?.dispose();

    final executor = joinDisponsabeObject(item: _functionality.createOperator(identifier: identifier));
    _waiter = joinWaiter();
    _executor = executor;

    maxiScheduleMicrotask(() async {
      try {
        final result = await executor.waitResult(onItem: (x) => _itemStreamController.addIfActive(x));
        _lastResult = result;
        _successfullyCompleted = true;
        _waiter.completeIfIncomplete(result);
      } catch (ex, st) {
        _lastError = NegativeResult.searchNegativity(item: ex, stackTrace: st, actionDescription: const Oration(message: 'Execute funcinality'));
        _successfullyCompleted = false;
        _waiter.completeErrorIfIncomplete(ex, st);
      } finally {
        _isActive = false;
        _executor = null;
      }
    });
  }
}
