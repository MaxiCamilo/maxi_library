import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tools/remote_functionality_executor_stream/remote_functionalities_executor_stream.dart';

class CreateNewExternalTask with TextableFunctionality<dynamic> {
  final int identifier;
  final Map<String, dynamic> rawData;
  final RemoteFunctionalitiesExecutorStream mainOperator;

  InteractableFunctionalityOperator? _executor;

  CreateNewExternalTask({required this.identifier, required this.rawData, required this.mainOperator});

  @override
  Future<void> runFunctionality({required InteractableFunctionalityExecutor<Oration, dynamic> manager}) async {
    final parameters = InvocationParameters.interpretFromJson(rawData.getRequiredValueWithSpecificType<String>('parameters'));
    final entityReflector = ReflectionManager.getReflectionEntityByName(rawData.getRequiredValueWithSpecificType<String>('functionality'));

    final entity = entityReflector.buildEntity(fixedParametersValues: parameters.fixedParameters, namedParametersValues: parameters.namedParameters) as TextableFunctionality;
    _executor = entity.createOperator(identifier: identifier);
    return _executor!.waitResult(
      onItem: (item) => manager.sendItem(item),
    );
  }

  @override
  void onCancel({required InteractableFunctionalityExecutor<Oration, dynamic> manager}) {
    super.onCancel(manager: manager);
    _executor?.cancel();
  }
}
