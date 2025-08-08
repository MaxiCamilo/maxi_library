import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/internal/isolated_shared_functionality_instance.dart';

class IsolatedSharedFunctionalityExecutor<I, R> with InteractiveFunctionality<I, R> {
  final IsolatedSharedFunctionality<I, R> mainOperator;
  final bool reRunIfActive;
  final bool cancelAlsoOnInstance;

  const IsolatedSharedFunctionalityExecutor({
    required this.mainOperator,
    required this.reRunIfActive,
    required this.cancelAlsoOnInstance,
  });

  @override
  Future<R> runFunctionality({required InteractiveFunctionalityExecutor<I, R> manager}) async {
    await mainOperator.initialize();

    manager.joinEvent(
      event: mainOperator.itemStream,
      onData: (x) => manager.sendItem(x),
    );

    return await manager.waitFuture(
      future: mainOperator.executeFromInstance(
        parameters: InvocationParameters.only(reRunIfActive),
        function: _runFUnctionalityStatic<I, R>,
      ),
    );
  }

  static Future<R> _runFUnctionalityStatic<I, R>(IsolatedSharedFunctionalityInstance<I, R> inst, InvocationParameters para) async {
    await inst.execute(reRunIfActive: para.firts<bool>());
    return await inst.waitResult();
  }

  @override
  void onCancel({required InteractiveFunctionalityExecutor<I, R> manager}) {
    super.onCancel(manager: manager);
    if (cancelAlsoOnInstance) {
      mainOperator.executeFromInstance(function: (inst, para) => inst.cancel());
    }
  }
}
