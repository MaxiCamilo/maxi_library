import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/singletons/isolated_interacting_functionalities_manager.dart';

class IsolatedInteractableFuncionalityExecutor<I, R> {
  final int identifier;
  final InteractableFunctionality<I, R> functionality;
  final IThreadInvoker invoker;

  late final InteractableFunctionalityOperator<I, R> _executor;

  final _onDone = MaxiCompleter();

  IsolatedInteractableFuncionalityExecutor({required this.identifier, required this.functionality, required this.invoker}) {
    _executor = functionality.createOperator(identifier: identifier);
    maxiScheduleMicrotask(_runFunctionality);
  }

  Future get onDone => _onDone.future;

  Future<void> _runFunctionality() async {
    try {
      final result = await _executor.waitResult(onItem: _sendItem);
      _sendResult(result);
    } catch (ex, st) {
      _sendError(ex, st);
    }

    _onDone.completeIfIncomplete();
  }

  void cancel() {
    _executor.cancel();
  }

  void _sendItem(I item) {
    invoker.callFunction(parameters: InvocationParameters.list([identifier, item]), function: _sendItemOnThread);
  }

  static void _sendItemOnThread(InvocationContext parameters) {
    IsolatedInteractingFunctionalitiesManager.singleton.receiveItem(id: parameters.firts<int>(), item: parameters.second());
  }

  void _sendResult(R result) {
    invoker.callFunction(parameters: InvocationParameters.list([identifier, result]), function: _sendResultOnThread);
  }

  static void _sendResultOnThread(InvocationContext parameters) {
    IsolatedInteractingFunctionalitiesManager.singleton.receiveResult(id: parameters.firts<int>(), result: parameters.second());
  }

  void _sendError(Object ex, StackTrace st) {
    invoker.callFunction(
      parameters: InvocationParameters.list([identifier, NegativeResult.searchNegativity(item: ex, actionDescription: const Oration(message: 'Executing functionality on thread')), st]),
      function: _sendErrorOnThread,
    );
  }

  static void _sendErrorOnThread(InvocationContext parameters) {
    IsolatedInteractingFunctionalitiesManager.singleton.receiveError(
      id: parameters.firts<int>(),
      error: parameters.second<NegativeResult>(),
      stackTrace: parameters.third<StackTrace>(),
    );
  }
}
