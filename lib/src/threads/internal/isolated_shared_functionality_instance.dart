import 'dart:async';

import 'package:maxi_library/export_reflectors.dart';

class IsolatedSharedFunctionalityInstance<I, R> with IDisposable, PaternalFunctionality {
  final String name;
  InteractiveFunctionality<I, R> functionality;

  late StreamController<I> _itemStreamController;
  late StreamController<bool> _statusStreamController;
  late StreamController<R> _newResultStreamController;
  late StreamController<NegativeResult> _newErrorStreamController;

  bool _reExecutionPending = false;
  bool _resultWasPositive = false;
  Completer? _reexecutionWaiter;
  Completer<R>? _resultWaiter;

  late R _lastResult;
  NegativeResult _lastError = NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: const Oration(message: 'The functionality has not been implemented yet'));

  InteractiveFunctionalityOperator<I, R>? _actualExecutor;

  bool get isActive => _actualExecutor != null && !_actualExecutor!.wasDiscarded;
  bool get resultWasPositive => _resultWasPositive;
  R get lastResult => _lastResult;
  NegativeResult get lastError => _lastError;

  Stream<I> get itemStream => _itemStreamController.stream;
  Stream<bool> get statusStream => _statusStreamController.stream;
  Stream<R> get newResultStream => _newResultStreamController.stream;
  Stream<NegativeResult> get newErrorStream => _newErrorStreamController.stream;

  IsolatedSharedFunctionalityInstance({required this.name, required this.functionality}) {
    _itemStreamController = createEventController<I>(isBroadcast: true);
    _statusStreamController = createEventController<bool>(isBroadcast: true);
    _newResultStreamController = createEventController<R>(isBroadcast: true);
    _newErrorStreamController = createEventController<NegativeResult>(isBroadcast: true);
  }

  void cancel() {
    _actualExecutor?.cancel();
  }

  Future<void> changeFunctionality({required InteractiveFunctionality<I, R> newFunctionality}) async {
    if (_reExecutionPending) {
      await _reexecutionWaiter!.future;
    }

    _actualExecutor?.dispose();
    _actualExecutor = null;

    functionality = newFunctionality;
  }

  Future<R> waitResult() async {
    if (!isActive) {
      await execute(reRunIfActive: true);
    }

    _resultWaiter ??= joinWaiter();
    return await _resultWaiter!.future;
  }

  Future<void> execute({required bool reRunIfActive}) async {
    if (!reRunIfActive && isActive) {
      return;
    }

    if (_reExecutionPending) {
      await _reexecutionWaiter!.future;
      return;
    }

    _reExecutionPending = true;
    _reexecutionWaiter ??= joinWaiter();

    if (_actualExecutor != null) {
      await _actualExecutor!.onDispose;
    }

    _actualExecutor = joinDisponsabeObject(item: functionality.inBackground().createOperator());

    _actualExecutor!
        .waitResult(
      onItem: (item) => _itemStreamController.addIfActive(item),
    )
        .then(
      (x) {
        _lastResult = x;
        _resultWasPositive = true;
        _newResultStreamController.addIfActive(x);
        _resultWaiter?.completeIfIncomplete(x);
      },
    ).onError(
      (x, st) {
        final nr = NegativeResult.searchNegativity(item: x, actionDescription: const Oration(message: 'Execute Isolate Shared Functionality'), stackTrace: st);
        _lastError = nr;
        _resultWasPositive = false;
        _newErrorStreamController.addIfActive(nr);
        _resultWaiter?.completeErrorIfIncomplete(nr);
      },
    ).whenComplete(
      () {
        _actualExecutor = null;
        _statusStreamController.addIfActive(false);
        _resultWaiter = null;
      },
    );

    _statusStreamController.addIfActive(true);

    _reExecutionPending = false;
    _reexecutionWaiter?.completeIfIncomplete();
    _reexecutionWaiter = null;
  }
}
