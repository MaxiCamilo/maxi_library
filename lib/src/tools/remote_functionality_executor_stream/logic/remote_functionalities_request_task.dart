import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tools/remote_functionality_executor_stream/remote_functionalities_executor_stream.dart';

class RemoteFunctionalityRequestTask with TextableFunctionality<dynamic> {
  final int identifier;
  final Map<String, dynamic> rawData;
  final RemoteFunctionalitiesExecutorStream mainOperator;

  const RemoteFunctionalityRequestTask({required this.identifier, required this.rawData, required this.mainOperator});

  @override
  Future<void> runFunctionality({required InteractiveFunctionalityExecutor<Oration, dynamic> manager}) async {
    final parameters = InvocationParameters.interpretFromJson(rawData.getRequiredValueWithSpecificType<String>('parameters'));
    final entityReflector = ReflectionManager.getReflectionEntityByName(rawData.getRequiredValueWithSpecificType<String>('functionality'));

    final entity = entityReflector.buildEntity(fixedParametersValues: parameters.fixedParameters, namedParametersValues: parameters.namedParameters) as TextableFunctionality;
    return entity.inBackground().joinExecutor(manager);
  }
}
