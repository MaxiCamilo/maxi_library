import 'dart:async';
import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tools/remote_functionalities_executor/via_stream/remote_functionalities_executor_via_steam_package_flag.dart';

class RemoteFunctionalitiesExecutorViaStreamController with IDisposable {
  final RemoteFunctionalitiesExecutorViaStream mainManager;

  final _pendingStream = <int, FunctionalityStreamManager>{};
  final _extenalsStream = <int, (Type, StreamController<StreamState<Oration, dynamic>>)>{};

  RemoteFunctionalitiesExecutorViaStreamController({required this.mainManager});

  @override
  void performObjectDiscard() {}

  StreamStateTexts<T> executeStreamFunctionality<T, F extends IStreamFunctionality<T>>({
    required InvocationParameters parameters,
    required String buildName,
  }) async* {
    final taskID = await mainManager.sendTaskCoordinates(function: (waiter) async {
      final fixedParameters = volatile(detail: const Oration(message: 'Convert Fixed parameters to json'), function: () => ConverterUtilities.serializeToJson(parameters.fixedParameters));
      final namedParameters = volatile(detail: const Oration(message: 'Convert named parameters to json'), function: () => ConverterUtilities.serializeToJson(parameters.namedParameters));

      mainManager.sendPackage(
        flag: RFESPackageFlag.newStreamFunctionality,
        content: {
          namedParameterFlag: namedParameters,
          fixedParameterFlag: fixedParameters,
          typeFlag: F.toString(),
          builderFlag: buildName,
        },
      );
    });

    final externalController = StreamController<StreamState<Oration, dynamic>>();
    _extenalsStream[taskID] = (T, externalController);

    late final T result;
    final resultController = StreamController<StreamState<Oration, T>>();

    mainManager.joinFuture(
      waitFunctionalStream(
        stream: externalController.stream,
        onData: (x) => resultController.add(streamTextStatus(x)),
        onError: (ex) => resultController.addError(ex),
        onDoneOrCanceled: (x) => resultController.close(),
        onResult: (x) {
          if (x is T) {
            result = x;
          } else {
            resultController.addError(NegativeResult(identifier: NegativeResultCodes.wrongType, message: Oration(message: 'A result of type %1 was expected', textParts: [T])));
          }
        },
      ),
    );

    yield* resultController.stream.doOnCancel(() {
      declareStreamClose(taskID);
      externalController.close();
    });

    yield streamResult(result);
  }

  void declareStreamClose(int id) {
    final controller = _extenalsStream.remove(id);
    if (controller == null) {
      return;
    }

    mainManager.sendPackage(flag: RFESPackageFlag.cancelStream, content: {identifierFlag: id});
    controller.$2.close();
  }

  void processNewStreamFunctionality(Map<String, dynamic> data) {
    try {
      final typeName = data.getRequiredValueWithSpecificType<String>(typeFlag);

      final fixedParameters = data.getRequiredValueWithSpecificType<String>(fixedParameterFlag);
      final namedParameters = data.getRequiredValueWithSpecificType<String>(namedParameterFlag);
      final buildName = data.getRequiredValueWithSpecificType<String>(builderFlag);

      final instance = _createStreamFunctionality(
        buildName: buildName,
        typeName: typeName,
        parameters: InvocationParameters(
          fixedParameters: json.decode(fixedParameters) as List,
          namedParameters: ConverterUtilities.interpretToObjectJson(text: namedParameters),
        ),
      );

      _instanceNewStreamFunctionality(instance);
    } catch (ex, st) {
      final rn = NegativeResult.searchNegativity(item: ex, actionDescription: const Oration(message: 'Create stream task on server'), stackTrace: st);
      mainManager.sendPackage(flag: RFESPackageFlag.creationObjectResult, content: {isCorrectFlag: false, contentFlag: rn.serializeToJson()});
    }
  }

  IStreamFunctionality _createStreamFunctionality({
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

    if (newInstance is IStreamFunctionality) {
      return newInstance;
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: Oration(
          message: 'The entity %1 is not a valid stream functionality',
          textParts: [typeName],
        ),
      );
    }
  }

  void _instanceNewStreamFunctionality(IStreamFunctionality instance) {
    final id = mainManager.getNewID();

    mainManager.sendPackage(flag: RFESPackageFlag.creationObjectResult, content: {isCorrectFlag: true, identifierFlag: id});

    maxiScheduleMicrotask(() async {
      try {
        final instanceController = instance.createManager();
        _pendingStream[id] = instanceController;

        await waitFunctionalStream(
          stream: instanceController.start(),
          onDoneOrCanceled: (x) {
            _pendingStream.remove(id);
            mainManager.sendPackage(flag: RFESPackageFlag.streamEnded, content: {identifierFlag: id});
          },
          onData: (x) => mainManager.sendPackage(flag: RFESPackageFlag.streamSendText, content: {identifierFlag: id, contentFlag: x.serializeToJson()}),
          onResult: (x) => mainManager.sendPackage(flag: RFESPackageFlag.streamSendResult, content: {
            isCorrectFlag: true,
            identifierFlag: id,
            contentFlag: mainManager.serializeResult(x),
          }),
          onError: (ex) => mainManager.sendPackage(flag: RFESPackageFlag.streamSendError, content: {
            identifierFlag: id,
            contentFlag: NegativeResult.searchNegativity(item: ex, actionDescription: const Oration(message: 'Stream Error')),
          }),
        );
      } catch (ex, st) {
        final rn = NegativeResult.searchNegativity(
          item: ex,
          stackTrace: st,
          actionDescription: Oration(message: 'Executing remote functionality called %1', textParts: [instance.runtimeType.toString()]),
        );
        mainManager.sendPackage(flag: RFESPackageFlag.streamSendError, content: {
          isCorrectFlag: false,
          identifierFlag: id,
          contentFlag: rn.serializeToJson(),
        });
        mainManager.sendPackage(flag: RFESPackageFlag.streamEnded, content: {identifierFlag: id});
      }
    });
  }

  void cancelActiveStream(int id) {
    final controller = _pendingStream.remove(id);
    if (controller == null) {
      return;
    }

    controller.cancelStream();
  }

  void processStreamResult(Map<String, dynamic> data) {
    final taskID = data.getRequiredValueWithSpecificType<int>(identifierFlag);
    final controllerAndType = _extenalsStream.remove(taskID);
    if (controllerAndType == null) {
      return;
    }

    final type = controllerAndType.$1;
    final controller = controllerAndType.$2;
    final rawContent = data.getRequiredValue(contentFlag);

    if (type == dynamic || type.toString() == 'void') {
      controller.add(streamResult(null));
      controller.close();
      return;
    }

    final primitiesType = ConverterUtilities.isPrimitive(type);

    if (primitiesType == null) {
      controller.add(streamResult(ReflectionManager.interpretJson(rawText: rawContent, tryToCorrectNames: false)));
    } else {
      controller.add(streamResult(ConverterUtilities.convertSpecificPrimitive(type: primitiesType, value: rawContent)));
    }
  }

  void processStreamText(Map<String, dynamic> data) {
    final taskID = data.getRequiredValueWithSpecificType<int>(identifierFlag);
    final controllerAndType = _extenalsStream[taskID];
    if (controllerAndType == null) {
      return;
    }

    final controller = controllerAndType.$2;
    final rawContent = data.getRequiredValue(contentFlag);
    final text = Oration.interpretFromJson(text: rawContent);

    controller.add(streamTextStatus(text));
  }

  void processStreamError(Map<String, dynamic> data) {
    final taskID = data.getRequiredValueWithSpecificType<int>(identifierFlag);
    final controllerAndType = _extenalsStream[taskID];
    if (controllerAndType == null) {
      return;
    }

    final controller = controllerAndType.$2;
    final rawContent = data.getRequiredValue(contentFlag);
    final error = NegativeResult.interpretJson(jsonText: rawContent);

    controller.add(streamPartialError(error));
  }
}
