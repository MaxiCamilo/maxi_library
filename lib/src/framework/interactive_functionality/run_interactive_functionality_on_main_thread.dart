import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/framework/interactive_functionality/run_interactive_functionality_on_another_thread.dart';

class RunInteractiveFunctionalityOnMainThread<I, R> with InteractiveFunctionality<I, R> {
  final InteractiveFunctionality<I, R> anotherFunctionality;

  const RunInteractiveFunctionalityOnMainThread({required this.anotherFunctionality});

  @override
  Future<R> runFunctionality({required InteractiveFunctionalityExecutor<I, R> manager}) async {
    if (ApplicationManager.instance.isWeb) {
      return await anotherFunctionality.joinExecutor(manager);
    }

    if (ThreadManager.instance.isServer) {
      return await anotherFunctionality.joinExecutor(manager);
    } else {
      manager.checkActivity();
      return await RunInteractiveFunctionalityOnAnotherThread<I, R>(
        thread: (ThreadManager.instance as IThreadManagerClient).serverConnection,
        anotherFunctionality: anotherFunctionality,
      ).joinExecutor(manager);
    }
  }
}
