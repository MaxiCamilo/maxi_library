import 'dart:async';

import 'package:maxi_library/export_reflectors.dart';
import 'package:maxi_library/src/tools/remote_functionality_executor_stream/remote_functionalities_executor_stream.dart';
import 'package:maxi_library/src/tools/remote_functionality_executor_stream/remote_functionalities_executor_waiter.dart';

class CreateExternalWaiter<T, F extends TextableFunctionality<T>> with TextableFunctionality<T> {
  final RemoteFunctionalitiesExecutorStream mainOperator;
  final InvocationParameters parameters;

  RemoteFunctionalitiesExecutorWaiter<T>? _newTaskOperator;

  CreateExternalWaiter({
    required this.mainOperator,
    required this.parameters,
  });

  @override
  Future<T> runFunctionality({required InteractableFunctionalityExecutor<Oration, T> manager}) async {
    _newTaskOperator = await mainOperator.sendAndWait<T, F>(parameters);

    return await _newTaskOperator!.waitResult(onItem: (x) => manager.sendItem(x));
  }

  @override
  void onCancel({required InteractableFunctionalityExecutor<Oration, T> manager}) {
    super.onCancel(manager: manager);

    _newTaskOperator?.cancel();
  }

  @override
  void onManagerDispose() {
    super.onManagerDispose();

    _newTaskOperator?.dispose();
  }
}
