import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tools/remote_functionality_executor_stream/remote_functionalities_executor_stream.dart';
import 'package:maxi_library/src/tools/remote_functionality_executor_stream/remote_functionalities_executor_waiter.dart';

class CreateExternalUnknownWaiter<T> with TextableFunctionality<T> {
  final RemoteFunctionalitiesExecutorStream mainOperator;
  final InvocationParameters parameters;
  final String typeName;

  RemoteFunctionalitiesExecutorWaiter<T>? _newTaskOperator;

  CreateExternalUnknownWaiter({
    required this.mainOperator,
    required this.parameters,
    required this.typeName,
  });

  @override
  Future<T> runFunctionality({required InteractableFunctionalityExecutor<Oration, T> manager}) async {
    _newTaskOperator = await mainOperator.sendAndWaitUnknown<T>(parameters: parameters, type: typeName);

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
