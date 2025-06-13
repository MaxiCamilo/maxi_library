import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/isolates/thread_isolator_server.dart';

class RunInteractableFunctionalityOnBackgroud<I, R> with InteractableFunctionality<I, R> {
  final InteractableFunctionality<I, R> anotherFunctionality;

  InteractableFunctionalityOperator<I, R>? _functionalityOperator;

  RunInteractableFunctionalityOnBackgroud({required this.anotherFunctionality});

  @override
  FutureOr<R> runFunctionality({required InteractableFunctionalityExecutor<I, R> manager}) async {
    if (ApplicationManager.instance.isWeb) {
      return await anotherFunctionality.joinExecutor(manager);
    }

    if (ThreadManager.instance.isServer) {
      final reservedThread = await (ThreadManager.instance as ThreadIsolatorServer).backgroundManager.reserveThread();
      _functionalityOperator = anotherFunctionality.runInAnotherThread(invoker: reservedThread);
      _functionalityOperator!.onDispose.whenComplete(() => (ThreadManager.instance as ThreadIsolatorServer).backgroundManager.releaseThread(reservedThread));

      manager.checkActivity();
      return _functionalityOperator!.waitResult(onItem: (x) => manager.sendItem(x));
    } else {
      return await inThreadServer().joinExecutor(manager);
    }
  }

  @override
  void onCancel({required InteractableFunctionalityExecutor<I, R> manager}) {
    super.onCancel(manager: manager);
    _functionalityOperator?.cancel();
  }
}
