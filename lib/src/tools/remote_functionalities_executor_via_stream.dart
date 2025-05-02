import 'dart:async';
import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';

enum _PackageFlag {
  newFunctionality,
  newStreamFunctionality,
  creationObjectResult,
  declareClose,
  functionalityEnded,
  streamSendResult,
  streamSendText,
  streamSendError,
  streamEnded,
  checkConnection,
  confirmConnection,
  cancelStream,
}

class RemoteFunctionalitiesExecutorViaStream with IRemoteFunctionalitiesExecutor, StartableFunctionality, FunctionalityWithLifeCycle {
  final Stream<Map<String, dynamic>> receiver;
  final StreamSink<Map<String, dynamic>> sender;
  final Duration timeout;
  final bool confirmConnection;

  final _waiterSemaphore = Semaphore();
  final _creatorSemaphore = Semaphore();

  Completer<int>? _taskExecutionConfirm;
  Completer? _waitConfirmConnection;

  bool _senderClose = false;
  int _lastID = 1;

  final _pendingTasks = <int, MaxiCompleter>{};
  final _pendingStream = <int, FunctionalityStreamManager>{};
  final _extenalsStream = <int, (Type, StreamController<StreamState<Oration, dynamic>>)>{};

  static const _packageFlag = '&MxRFES&';
  static const _contentFlag = 'content';
  static const _namedParameterFlag = 'named';
  static const _fixedParameterFlag = 'fixed';
  static const _isCorrectFlag = 'isCorrect';
  static const _identifierFlag = 'identifier';
  static const _builderFlag = 'builder';
  static const _typeFlag = 'type';

  @override
  bool get isActive => isInitialized;

  RemoteFunctionalitiesExecutorViaStream({required this.receiver, required this.sender, required this.confirmConnection, this.timeout = const Duration(seconds: 7)});
  factory RemoteFunctionalitiesExecutorViaStream.filtrePackage({
    required Stream<Map<String, dynamic>> receiver,
    required StreamSink<Map<String, dynamic>> sender,
    required bool confirmConnection,
    Duration timeout = const Duration(seconds: 7),
  }) {
    return RemoteFunctionalitiesExecutorViaStream(
      sender: sender,
      timeout: timeout,
      confirmConnection: confirmConnection,
      receiver: receiver.where((x) => x.containsKey(_packageFlag)),
    );
  }

  @override
  Future<void> afterInitializingFunctionality() async {
    if (initiallyPreviouslyExecuted) {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: const Oration(message: 'This functionality cannot be reinitialized'),
      );
    }

    joinFuture(sender.done).whenComplete(() {
      _senderClose = true;
      dispose();
    });

    joinEvent(
      event: receiver,
      onData: _onReceivedData,
      onDone: () => dispose(),
    );

    await checkConnection();
  }

  Future<void> checkConnection() async {
    if (_waitConfirmConnection != null) {
      return _waitConfirmConnection!.future;
    }
    _waitConfirmConnection = MaxiCompleter();
    await makeSeveralAttemptsAsync(
        attempts: (timeout.inMilliseconds ~/ 200) + 1,
        function: () async {
          _sendPackage(flag: _PackageFlag.checkConnection);
          await _waitConfirmConnection?.future.timeout(
            Duration(milliseconds: 200),
            onTimeout: () {
              final error = NegativeResult(identifier: NegativeResultCodes.timeout, message: const Oration(message: 'The server took too long to confirm your activity'));
              _waitConfirmConnection?.completeErrorIfIncomplete(error);
              _waitConfirmConnection = null;

              if (isInitialized) {
                dispose();
              }

              throw error;
            },
          );
        });
  }

  void _sendPackage({required _PackageFlag flag, Map<String, dynamic> content = const {}}) {
    sender.add({_packageFlag: flag.index}..addAll(content));
  }

  @override
  void performObjectDiscard() {
    if (!_senderClose) {
      containErrorLog(detail: const Oration(message: 'Sending close flag'), function: () => _sendPackage(flag: _PackageFlag.declareClose));
    }
    super.performObjectDiscard();
  }

  @override
  Future<T> executeFunctionality<T, F extends IFunctionality<FutureOr<T>>>({InvocationParameters parameters = InvocationParameters.emptry, String buildName = ''}) async {
    await initialize();

    final taskID = await _waiterSemaphore.execute(function: () async {
      final fixedParameters = volatile(detail: const Oration(message: 'Convert Fixed parameters to json'), function: () => ConverterUtilities.serializeToJson(parameters.fixedParameters));
      final namedParameters = volatile(detail: const Oration(message: 'Convert named parameters to json'), function: () => ConverterUtilities.serializeToJson(parameters.namedParameters));

      _taskExecutionConfirm = joinWaiter<int>();
      _sendPackage(
        flag: _PackageFlag.newFunctionality,
        content: {
          _namedParameterFlag: namedParameters,
          _fixedParameterFlag: fixedParameters,
          _typeFlag: F.toString(),
          _builderFlag: buildName,
        },
      );
      try {
        return await _taskExecutionConfirm!.future.timeout(
          timeout,
          onTimeout: () => throw NegativeResult(
            identifier: NegativeResultCodes.timeout,
            message: const Oration(message: 'The server took too long to confirm the execution of the requested task'),
          ),
        );
      } finally {
        _taskExecutionConfirm = null;
      }
    });

    final waiter = MaxiCompleter<T>(waiterName: 'Remote Object Invocator');
    _pendingTasks[taskID] = waiter;

    return waiter.future;
  }

  @override
  StreamStateTexts<T> executeStreamFunctionality<T, F extends IStreamFunctionality<T>>({InvocationParameters parameters = InvocationParameters.emptry, String buildName = ''}) async* {
    await initialize();

    final taskID = await _waiterSemaphore.execute(function: () async {
      final fixedParameters = volatile(detail: const Oration(message: 'Convert Fixed parameters to json'), function: () => ConverterUtilities.serializeToJson(parameters.fixedParameters));
      final namedParameters = volatile(detail: const Oration(message: 'Convert named parameters to json'), function: () => ConverterUtilities.serializeToJson(parameters.namedParameters));

      _taskExecutionConfirm = joinWaiter<int>();
      _sendPackage(
        flag: _PackageFlag.newStreamFunctionality,
        content: {
          _namedParameterFlag: namedParameters,
          _fixedParameterFlag: fixedParameters,
          _typeFlag: F.toString(),
          _builderFlag: buildName,
        },
      );
      try {
        return await _taskExecutionConfirm!.future.timeout(
          timeout,
          onTimeout: () => throw NegativeResult(
            identifier: NegativeResultCodes.timeout,
            message: const Oration(message: 'The server took too long to confirm the execution of the requested task'),
          ),
        );
      } finally {
        _taskExecutionConfirm = null;
      }
    });

    final externalController = StreamController<StreamState<Oration, dynamic>>();
    _extenalsStream[taskID] = (T, externalController);

    late final T result;
    final resultController = StreamController<StreamState<Oration, T>>();

    joinFuture(
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
      _cancelStream(taskID);
      externalController.close();
    });

    yield streamResult(result);
  }

  void _cancelStream(int id) {
    final controller = _extenalsStream.remove(id);
    if (controller == null) {
      return;
    }

    _sendPackage(flag: _PackageFlag.cancelStream, content: {_identifierFlag: id});
    controller.$2.close();
  }

  void _onReceivedData(Map<String, dynamic> data) {
    final rawFlag = data.getRequiredValueWithSpecificType<int>(_packageFlag);
    final flag = volatile(detail: const Oration(message: 'Convert number to package flag'), function: () => _PackageFlag.values[rawFlag]);

    switch (flag) {
      case _PackageFlag.creationObjectResult:
        _processConfirmation(data);
        break;
      case _PackageFlag.newFunctionality:
        _creatorSemaphore.execute(function: () => _processNewFunctionality(data));
        break;
      case _PackageFlag.newStreamFunctionality:
        _creatorSemaphore.execute(function: () => _processNewStreamFunctionality(data));
        break;
      case _PackageFlag.functionalityEnded:
        _processFunctionalityEnded(data);
        break;
      case _PackageFlag.checkConnection:
        _sendPackage(flag: _PackageFlag.confirmConnection);
        break;
      case _PackageFlag.confirmConnection:
        _waitConfirmConnection?.completeIfIncomplete();
        _waitConfirmConnection = null;
        break;
      case _PackageFlag.declareClose:
        sender.close();
        break;
      case _PackageFlag.streamSendResult:
        _processStreamResult(data);
        break;
      case _PackageFlag.streamSendText:
        _processStreamText(data);
        break;
      case _PackageFlag.streamSendError:
        _processStreamError(data);
        break;
      case _PackageFlag.streamEnded:
        _cancelStream(data.getRequiredValueWithSpecificType<int>(_identifierFlag));
        break;
      case _PackageFlag.cancelStream:
        final id = data.getRequiredValueWithSpecificType<int>(_identifierFlag);
        final item = _pendingStream.remove(id);
        if (item != null) {
          item.cancelStream();
        }
        break;
    }
  }

  void _processNewFunctionality(Map<String, dynamic> data) {
    try {
      final typeName = data.getRequiredValueWithSpecificType<String>(_typeFlag);

      final fixedParameters = data.getRequiredValueWithSpecificType<String>(_fixedParameterFlag);
      final namedParameters = data.getRequiredValueWithSpecificType<String>(_namedParameterFlag);
      final buildName = data.getRequiredValueWithSpecificType<String>(_builderFlag);

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
      _sendPackage(flag: _PackageFlag.creationObjectResult, content: {_isCorrectFlag: false, _contentFlag: rn.serializeToJson()});
    }
  }

  void _instanceNewFunctionality(IFunctionality<FutureOr<dynamic>> instance) {
    final id = _lastID;
    _lastID += 1;

    _sendPackage(flag: _PackageFlag.creationObjectResult, content: {_isCorrectFlag: true, _identifierFlag: id});

    maxiScheduleMicrotask(() async {
      try {
        final result = await instance.runFunctionality();
        final jsonResult = _serializeResult(result);
        _sendPackage(flag: _PackageFlag.functionalityEnded, content: {
          _isCorrectFlag: true,
          _identifierFlag: id,
          _contentFlag: jsonResult,
        });
      } catch (ex, st) {
        final rn = NegativeResult.searchNegativity(
          item: ex,
          stackTrace: st,
          actionDescription: Oration(message: 'Executing remote functionality called %1', textParts: [instance.runtimeType.toString()]),
        );
        _sendPackage(flag: _PackageFlag.functionalityEnded, content: {
          _isCorrectFlag: false,
          _identifierFlag: id,
          _contentFlag: rn.serializeToJson(),
        });
      }
    });
  }

  void _processNewStreamFunctionality(Map<String, dynamic> data) {
    try {
      final typeName = data.getRequiredValueWithSpecificType<String>(_typeFlag);

      final fixedParameters = data.getRequiredValueWithSpecificType<String>(_fixedParameterFlag);
      final namedParameters = data.getRequiredValueWithSpecificType<String>(_namedParameterFlag);
      final buildName = data.getRequiredValueWithSpecificType<String>(_builderFlag);

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
      _sendPackage(flag: _PackageFlag.creationObjectResult, content: {_isCorrectFlag: false, _contentFlag: rn.serializeToJson()});
    }
  }

  dynamic _serializeResult(result) => volatile(
      detail: const Oration(message: 'Serialize result'),
      function: () {
        if (result == null) {
          return '';
        }
        final type = ConverterUtilities.isPrimitive(result.runtimeType);
        return type == null ? ConverterUtilities.serializeToJson(result) : ConverterUtilities.primitiveClone(result);
      });

  void _instanceNewStreamFunctionality(IStreamFunctionality instance) {
    final id = _lastID;
    _lastID += 1;

    _sendPackage(flag: _PackageFlag.creationObjectResult, content: {_isCorrectFlag: true, _identifierFlag: id});

    maxiScheduleMicrotask(() async {
      Future<dynamic>? whenOnDispose;
      try {
        final instanceController = instance.createManager();
        _pendingStream[id] = instanceController;

        whenOnDispose = onDispose.whenComplete(() => instanceController.cancelStream());
        await waitFunctionalStream(
          stream: instanceController.start(),
          onDoneOrCanceled: (x) {
            whenOnDispose?.ignore();
            _pendingStream.remove(id);
            _sendPackage(flag: _PackageFlag.streamEnded, content: {_identifierFlag: id});
          },
          onData: (x) => _sendPackage(flag: _PackageFlag.streamSendText, content: {_identifierFlag: id, _contentFlag: x.serializeToJson()}),
          onResult: (x) => _sendPackage(flag: _PackageFlag.streamSendResult, content: {
            _isCorrectFlag: true,
            _identifierFlag: id,
            _contentFlag: _serializeResult(x),
          }),
          onError: (ex) => _sendPackage(flag: _PackageFlag.streamSendError, content: {
            _identifierFlag: id,
            _contentFlag: NegativeResult.searchNegativity(item: ex, actionDescription: const Oration(message: 'Stream Error')),
          }),
        );
      } catch (ex, st) {
        whenOnDispose?.ignore();
        final rn = NegativeResult.searchNegativity(
          item: ex,
          stackTrace: st,
          actionDescription: Oration(message: 'Executing remote functionality called %1', textParts: [instance.runtimeType.toString()]),
        );
        _sendPackage(flag: _PackageFlag.streamSendError, content: {
          _isCorrectFlag: false,
          _identifierFlag: id,
          _contentFlag: rn.serializeToJson(),
        });
        _sendPackage(flag: _PackageFlag.streamEnded, content: {_identifierFlag: id});
      }
    });
  }

  void _processConfirmation(Map<String, dynamic> data) {
    final isCorrect = data.getRequiredValueWithSpecificType<bool>(_isCorrectFlag);
    if (isCorrect) {
      final id = data.getRequiredValueWithSpecificType<int>(_identifierFlag);
      _taskExecutionConfirm?.completeIfIncomplete(id);
    } else {
      final error = NegativeResult.interpretJson(jsonText: data.getRequiredValueWithSpecificType<String>(_contentFlag), checkTypeFlag: true);
      _taskExecutionConfirm?.completeErrorIfIncomplete(error, StackTrace.fromString(error.stackTrace));
    }

    _taskExecutionConfirm = null;
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

  void _processFunctionalityEnded(Map<String, dynamic> data) {
    final taskID = data.getRequiredValueWithSpecificType<int>(_identifierFlag);
    final taskWaiter = _pendingTasks.remove(taskID);
    if (taskWaiter == null) {
      return;
    }

    final isCorrect = data.getRequiredValueWithSpecificType<bool>(_isCorrectFlag);
    final rawContent = data.getRequiredValue(_contentFlag);

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

  void _processStreamResult(Map<String, dynamic> data) {
    final taskID = data.getRequiredValueWithSpecificType<int>(_identifierFlag);
    final controllerAndType = _extenalsStream.remove(taskID);
    if (controllerAndType == null) {
      return;
    }

    final type = controllerAndType.$1;
    final controller = controllerAndType.$2;
    final rawContent = data.getRequiredValue(_contentFlag);

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

  void _processStreamText(Map<String, dynamic> data) {
    final taskID = data.getRequiredValueWithSpecificType<int>(_identifierFlag);
    final controllerAndType = _extenalsStream[taskID];
    if (controllerAndType == null) {
      return;
    }

    final controller = controllerAndType.$2;
    final rawContent = data.getRequiredValue(_contentFlag);
    final text = Oration.interpretFromJson(text: rawContent);

    controller.add(streamTextStatus(text));
  }

  void _processStreamError(Map<String, dynamic> data) {
    final taskID = data.getRequiredValueWithSpecificType<int>(_identifierFlag);
    final controllerAndType = _extenalsStream[taskID];
    if (controllerAndType == null) {
      return;
    }

    final controller = controllerAndType.$2;
    final rawContent = data.getRequiredValue(_contentFlag);
    final error = NegativeResult.interpretJson(jsonText: rawContent);

    controller.add(streamPartialError(error));
  }
}
