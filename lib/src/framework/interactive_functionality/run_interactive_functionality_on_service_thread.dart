import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class RunInteractiveFunctionalityOnServiceThread<S extends Object, I, R> with InteractiveFunctionality<I, R> {
  final InteractiveFunctionality<I, R> anotherFunctionality;

  const RunInteractiveFunctionalityOnServiceThread({required this.anotherFunctionality});

  @override
  Future<R> runFunctionality({required InteractiveFunctionalityExecutor<I, R> manager}) async {
    if (ThreadManager.instance.isServer || ThreadManager.instance.entityType != S) {
      final thread = await ThreadManager.instance.getEntityInstance<S>();
      if (thread == null) {
        throw NegativeResult(
          identifier: NegativeResultCodes.nonExistent,
          message: Oration(message: 'The %1 service was not mounted', textParts: [S]),
        );
      }

      return await anotherFunctionality.inAnotherThread(invoker: thread).joinExecutor(manager);
    } else {
      return await anotherFunctionality.joinExecutor(manager);
    }
  }
}
