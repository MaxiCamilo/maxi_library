import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tools/remote_functionalities_executor/via_stream/remote_functionalities_executor_package_flag.dart';

class RemoteFunctionalitiesExecutorThreadEntity with IDisposable {
  final RemoteFunctionalitiesExecutorViaStream mainManager;

  final _externalsInvocations = <int, MaxiCompleter>{};

  RemoteFunctionalitiesExecutorThreadEntity({required this.mainManager});

  @override
  void performObjectDiscard() {}

  Future<R> executeReflectedEntityFunction<R>({required String entityName, required String methodName, required InvocationParameters parameters}) async {
    final taskID = await mainManager.sendTaskCoordinates(function: (waiter) async {
      final fixedParameters = volatile(detail: const Oration(message: 'Convert Fixed parameters to json'), function: () => ConverterUtilities.serializeToJson(parameters.fixedParameters));
      final namedParameters = volatile(detail: const Oration(message: 'Convert named parameters to json'), function: () => ConverterUtilities.serializeToJson(parameters.namedParameters));

      mainManager.sendPackage(
        flag: RFESPackageFlag.newEntityFunctionality,
        content: {
          namedParameterFlag: namedParameters,
          fixedParameterFlag: fixedParameters,
          methodFlag: methodName,
          typeFlag: entityName,
        },
      );
    });
    final waiter = MaxiCompleter<R>(waiterName: 'Remote Object Invocator');
    _externalsInvocations[taskID] = waiter;

    return waiter.future;
  }

  void processNewEntityFunctionality(Map<String, dynamic> data) async {
    final id = mainManager.getNewID();
    mainManager.sendPackage(flag: RFESPackageFlag.creationObjectResult, content: {isCorrectFlag: true, identifierFlag: id});
    String typeName = '<¿?>';
    try {
      typeName = data.getRequiredValueWithSpecificType<String>(typeFlag);

      final fixedParameters = data.getRequiredValueWithSpecificType<String>(fixedParameterFlag);
      final namedParameters = data.getRequiredValueWithSpecificType<String>(namedParameterFlag);
      final methodName = data.getRequiredValueWithSpecificType<String>(methodFlag);

      final entityInstance = await ThreadManager.instance.getEntityInstanceByName(name: typeName);
      if (entityInstance == null) {
        throw NegativeResult(
          identifier: NegativeResultCodes.nonExistent,
          message: Oration(
            message: 'The server does not have the isolated entity named %1',
            textParts: [typeName],
          ),
        );
      }

      final result = await entityInstance.callFunction(parameters: InvocationParameters.list([typeName, methodName, fixedParameters, namedParameters]), function: _callReflectedMethodOnThread);
      if (wasDiscarded) {
        return;
      }
      mainManager.sendPackage(
        flag: RFESPackageFlag.entityFunctionalityEnd,
        content: {identifierFlag: id, isCorrectFlag: true, contentFlag: ConverterUtilities.isPrimitive(result.runtimeType) == null ? ConverterUtilities.serializeToJson(result) : result},
      );
    } catch (ex, st) {
      if (wasDiscarded) {
        return;
      }
      final rn = NegativeResult.searchNegativity(item: ex, actionDescription: Oration(message: 'Call entity function %1 on server', textParts: [typeName]), stackTrace: st);
      mainManager.sendPackage(flag: RFESPackageFlag.entityFunctionalityEnd, content: {identifierFlag: id, isCorrectFlag: false, contentFlag: rn.serializeToJson()});
    }
  }

  void processFinishedFunction(Map<String, dynamic> data) {
    final taskID = data.getRequiredValueWithSpecificType<int>(identifierFlag);
    final taskWaiter = _externalsInvocations.remove(taskID);
    if (taskWaiter == null) {
      return;
    }

    final isCorrect = data.getRequiredValueWithSpecificType<bool>(isCorrectFlag);
    final rawContent = data.getRequiredValue(contentFlag);

    try {
      if (!isCorrect) {
        final error = NegativeResult.interpretJson(jsonText: rawContent);
        taskWaiter.completeError(error, StackTrace.fromString(error.stackTrace));
        return;
      }

      if (taskWaiter.expectedType == dynamic || taskWaiter.expectedType.toString() == 'void') {
        taskWaiter.complete(rawContent);
        return;
      }

      final primitiesType = ConverterUtilities.isPrimitive(taskWaiter.expectedType);

      if (primitiesType == null) {
        taskWaiter.complete(ReflectionManager.interpretJson(rawText: rawContent, tryToCorrectNames: false));
      } else {
        taskWaiter.complete(ConverterUtilities.convertSpecificPrimitive(type: primitiesType, value: rawContent));
      }
    } catch (ex, st) {
      taskWaiter.completeError(ex, st);
    }
  }

  static Future<dynamic> _callReflectedMethodOnThread(InvocationContext context) async {
    final threadType = context.thread.entityType;
    final name = context.firts<String>();
    final methodName = context.second<String>();
    final fixedParameters = context.third<String>();
    final namedParameters = context.fourth<String>();

    checkProgrammingFailure(
        thatChecks: Oration(
          message: 'Thread %1 is %2',
          textParts: [threadType.toString(), name],
        ),
        result: () => threadType.toString() == name);

    final reflector = ReflectionManager.getReflectionEntityByName(name);
    final result = reflector.callMethod(
      name: methodName,
      instance: await context.thread.getEntity(),
      fixedParametersValues: ConverterUtilities.interpretJson(text: fixedParameters),
      namedParametesValues: ConverterUtilities.interpretToObjectJson(text: namedParameters),
    );

    if (result is Future) {
      return await result;
    } else {
      return result;
    }
  }
}
