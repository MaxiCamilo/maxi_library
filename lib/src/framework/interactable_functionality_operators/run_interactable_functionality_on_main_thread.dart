import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/framework/interactable_functionality_operators/isolated_interactable_functionality_operator.dart';

class RunInteractableFunctionalityOnMainThread<I, R> with InteractableFunctionality<I, R> {
  final InteractableFunctionality<I, R> anotherFunctionality;

  InteractableFunctionalityOperator<I, R>? _functionalityOperator;

  RunInteractableFunctionalityOnMainThread({required this.anotherFunctionality});

  @override
  FutureOr<R> runFunctionality({required InteractableFunctionalityExecutor<I, R> manager}) async {
    if (ApplicationManager.instance.isWeb) {
      return await anotherFunctionality.joinExecutor(manager);
    }

    if (ThreadManager.instance.isServer) {
      return await anotherFunctionality.joinExecutor(manager);
    } else {
      manager.checkActivity();
      _functionalityOperator = IsolatedInteractableFunctionalityOperator<I, R>(invokerGetter: () => (ThreadManager.instance as IThreadManagerClient).serverConnection, functionality: anotherFunctionality);
      return await _functionalityOperator!.waitResult(onItem: manager.sendItem);
    }
  }

  @override
  void onCancel({required InteractableFunctionalityExecutor<I, R> manager}) {
    super.onCancel(manager: manager);
    _functionalityOperator?.cancel();
  }
}
