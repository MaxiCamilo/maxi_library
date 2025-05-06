import 'dart:async';
import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tools/remote_functionalities_executor/via_stream/remote_functionalities_executor_package_flag.dart';

class RemoteFunctionalitiesExecutorFunctions with IDisposable {
  final RemoteFunctionalitiesExecutorViaStream mainManager;

  final _externalsInvocations = <int, MaxiCompleter>{};
  final _executionTasks = <int, FutureOr>{};

  RemoteFunctionalitiesExecutorFunctions({required this.mainManager});

  @override
  void performObjectDiscard() {
    _executionTasks.entries.iterar((x) {
      if (x.value is Future) {
        (x.value as Future).ignore();
      }
    });

    _externalsInvocations.entries
        .iterar((x) => x.value.completeErrorIfIncomplete(NegativeResult(identifier: NegativeResultCodes.functionalityCancelled, message: const Oration(message: 'The server concluded its execution'))));

    _executionTasks.clear();
    _externalsInvocations.clear();
  }

  Future<T> requestInvocation<T, F extends IFunctionality<FutureOr<T>>>({
    required InvocationParameters parameters,
    required String buildName,
  }) async {
    final taskID = await mainManager.sendTaskCoordinates(function: (waiter) async {
      final fixedParameters = volatile(detail: const Oration(message: 'Convert Fixed parameters to json'), function: () => ConverterUtilities.serializeToJson(parameters.fixedParameters));
      final namedParameters = volatile(detail: const Oration(message: 'Convert named parameters to json'), function: () => ConverterUtilities.serializeToJson(parameters.namedParameters));

      mainManager.sendPackage(
        flag: RFESPackageFlag.newFunctionality,
        content: {
          namedParameterFlag: namedParameters,
          fixedParameterFlag: fixedParameters,
          typeFlag: F.toString(),
          builderFlag: buildName,
        },
      );
    });
    final waiter = MaxiCompleter<T>(waiterName: 'Remote Object Invocator');
    _externalsInvocations[taskID] = waiter;

    return waiter.future;
  }

  void processFinishedExternalRequest(Map<String, dynamic> data) {
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
        taskWaiter.complete();
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

  void processNewFunctionality(Map<String, dynamic> data) {
    try {
      final typeName = data.getRequiredValueWithSpecificType<String>(typeFlag);

      final fixedParameters = data.getRequiredValueWithSpecificType<String>(fixedParameterFlag);
      final namedParameters = data.getRequiredValueWithSpecificType<String>(namedParameterFlag);
      final buildName = data.getRequiredValueWithSpecificType<String>(builderFlag);

      final instance = _createFunctionality(
        buildName: buildName,
        typeName: typeName,
        parameters: InvocationParameters(
          fixedParameters: json.decode(fixedParameters) as List,
          namedParameters: ConverterUtilities.interpretToObjectJson(text: namedParameters),
        ),
      );

      _instanceNewFunctionality(instance);
    } catch (ex, st) {
      final rn = NegativeResult.searchNegativity(item: ex, actionDescription: const Oration(message: 'Create task on server'), stackTrace: st);
      mainManager.sendPackage(flag: RFESPackageFlag.creationObjectResult, content: {isCorrectFlag: false, contentFlag: rn.serializeToJson()});
    }
  }

  IFunctionality<FutureOr> _createFunctionality({
    required InvocationParameters parameters,
    required String buildName,
    required String typeName,
  }) {
    final classInstance = ReflectionManager.getReflectionEntityByName(typeName);
    final newInstance = classInstance.buildEntity(
      selectedBuild: buildName,
      fixedParametersValues: parameters.fixedParameters,
      namedParametersValues: parameters.namedParameters,
    );

    if (newInstance is IFunctionality<FutureOr>) {
      return newInstance;
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: Oration(
          message: 'The entity %1 is not a valid functionality',
          textParts: [typeName],
        ),
      );
    }
  }

  void _instanceNewFunctionality(IFunctionality<FutureOr<dynamic>> instance) {
    final id = mainManager.getNewID();

    mainManager.sendPackage(flag: RFESPackageFlag.creationObjectResult, content: {isCorrectFlag: true, identifierFlag: id});

    maxiScheduleMicrotask(() async {
      final futureFunction = instance.runFunctionality();
      _executionTasks[id] = futureFunction;

      try {
        final result = await futureFunction;

        final jsonResult = mainManager.serializeResult(result);
        mainManager.sendPackage(flag: RFESPackageFlag.functionalityEnded, content: {
          isCorrectFlag: true,
          identifierFlag: id,
          contentFlag: jsonResult,
        });
      } catch (ex, st) {
        final rn = NegativeResult.searchNegativity(
          item: ex,
          stackTrace: st,
          actionDescription: Oration(message: 'Executing remote functionality called %1', textParts: [instance.runtimeType.toString()]),
        );
        mainManager.sendPackage(flag: RFESPackageFlag.functionalityEnded, content: {
          isCorrectFlag: false,
          identifierFlag: id,
          contentFlag: rn.serializeToJson(),
        });
      } finally {
        _executionTasks.remove(id);
      }
    });
  }
}
