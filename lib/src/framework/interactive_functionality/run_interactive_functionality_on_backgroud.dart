import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/isolates/thread_isolator_server.dart';

class RunInteractiveFunctionalityOnBackgroud<I, R> with InteractiveFunctionality<I, R> {
  final InteractiveFunctionality<I, R> anotherFunctionality;

  const RunInteractiveFunctionalityOnBackgroud({required this.anotherFunctionality});

  @override
  Future<R> runFunctionality({required InteractiveFunctionalityExecutor<I, R> manager}) async {
    if (ApplicationManager.instance.isWeb) {
      return await anotherFunctionality.joinExecutor(manager);
    }

    if (ThreadManager.instance.isServer) {
      final reservedThread = await (ThreadManager.instance as ThreadIsolatorServer).backgroundManager.reserveThread();
      final functionalityOperator = anotherFunctionality.inAnotherThread(invoker: reservedThread).createOperator(identifier: manager.identifier);
      functionalityOperator.onDispose.whenComplete(() => (ThreadManager.instance as ThreadIsolatorServer).backgroundManager.releaseThread(reservedThread));

      manager.checkActivity();
      return await functionalityOperator.waitResult(onItem: (x) => manager.sendItem(x));
    } else {
      return await inThreadServer().joinExecutor(manager);
    }
  }
}
