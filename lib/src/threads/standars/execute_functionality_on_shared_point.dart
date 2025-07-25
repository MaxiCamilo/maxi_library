import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/singletons/shared_pointer_manager.dart';

class ExecuteFunctionalityOnSharedPoint<T, I, R> with InteractiveFunctionality<I, R> {
  final int threadID;
  final int identifier;
  final InteractiveFunctionality<I, R> Function(T item, InvocationParameters para) function;
  final InvocationParameters parameters;

  const ExecuteFunctionalityOnSharedPoint({required this.threadID, required this.identifier, required this.function, required this.parameters});

  Future<IThreadInvokeInstance> _getInvokator() async {
    final invokaror = await ThreadManager.instance.getIDInstance(id: threadID);

    if (invokaror == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: Oration(
          message: 'There is no thread number %1',
          textParts: [identifier],
        ),
      );
    }

    return invokaror;
  }

  @override
  Future<R> runFunctionality({required InteractiveFunctionalityExecutor<I, R> manager}) async {
    if (threadID != ThreadManager.instance.threadID) {
      return await inAnotherThread(invoker: await _getInvokator()).joinExecutor(manager);
    }

    final value = SharedPointerManager.singleton.getItem<T>(identifier: identifier);
    final newFunc = function(value, parameters);

    return await newFunc.joinExecutor(manager);
  }
}
