import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

enum _PackageFlag {
  newFunctionality,
  creationObjectResult,
  declareClose,
}

class RemoteFunctionalitiesExecutorViaStream with IRemoteFunctionalitiesExecutor, StartableFunctionality, FunctionalityWithLifeCycle {
  final Stream<Map<String, dynamic>> receiver;
  final StreamSink<Map<String, dynamic>> sender;
  final Duration timeout;

  final _waiterSemaphore = Semaphore();
  final _creatorSemaphore = Semaphore();

  Completer<int>? taskResult;

  bool _senderClose = false;
  int _lastID = 1;

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

  RemoteFunctionalitiesExecutorViaStream({required this.receiver, required this.sender, this.timeout = const Duration(seconds: 7)});
  factory RemoteFunctionalitiesExecutorViaStream.filtrePackage({
    required Stream<Map<String, dynamic>> receiver,
    required StreamSink<Map<String, dynamic>> sender,
    Duration timeout = const Duration(seconds: 7),
  }) {
    return RemoteFunctionalitiesExecutorViaStream(
      sender: sender,
      timeout: timeout,
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

    final taskID = _waiterSemaphore.execute(function: () async {
      final fixedParameters = volatile(detail: const Oration(message: 'Convert Fixed parameters to json'), function: () => ConverterUtilities.toJsonString(parameters.fixedParameters));
      final namedParameters = volatile(detail: const Oration(message: 'Convert named parameters to json'), function: () => ConverterUtilities.toJsonString(parameters.namedParameters));

      taskResult = joinWaiter<int>();
      _sendPackage(
        flag: _PackageFlag.newFunctionality,
        content: {
          _namedParameterFlag: namedParameters,
          _fixedParameterFlag: fixedParameters,
          _typeFlag: F.toString(),
          _builderFlag: buildName,
        },
      );
      return taskResult!.future;
    });
  }

  @override
  StreamStateTexts<T> executeStreamFunctionality<T, F extends IStreamFunctionality<T>>({InvocationParameters parameters = InvocationParameters.emptry, String buildName = ''}) async* {
    await initialize();
  }

  void _onReceivedData(Map<String, dynamic> data) {
    final rawFlag = data.getRequiredValueWithSpecificType<int>(_packageFlag);
    final flag = volatile(detail: const Oration(message: 'Convert number to package flag'), function: () => _PackageFlag.values[rawFlag]);

    switch (flag) {
      case _PackageFlag.newFunctionality:
        _creatorSemaphore.execute(function: () => _processNewFunctionality(data));
        break;
      case _PackageFlag.creationObjectResult:
        _processConfirmation(data);
        break;
      case _PackageFlag.declareClose:
        sender.close();
        break;
    }
  }

  void _processNewFunctionality(Map<String, dynamic> data) {
    final typeName = data.getRequiredValueWithSpecificType<String>(_typeFlag);

    final fixedParameters = data.getRequiredValueWithSpecificType<String>(_typeFlag);
    final namedParameters = data.getRequiredValueWithSpecificType<String>(_typeFlag);
  }

  void _processConfirmation(Map<String, dynamic> data) {
    final isCorrect = data.getRequiredValueWithSpecificType<bool>(_isCorrectFlag);
    if (isCorrect) {
      final id = data.getRequiredValueWithSpecificType<int>(_identifierFlag);
      taskResult?.completeIfIncomplete(id);
    } else {
      final error = NegativeResult.interpretJson(jsonText: data.getRequiredValueWithSpecificType<String>(_contentFlag), checkTypeFlag: true);
      taskResult?.completeErrorIfIncomplete(error);
    }

    taskResult = null;
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
}
