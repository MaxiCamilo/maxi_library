import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tools/remote_functionalities_executor/via_stream/remote_functionalities_executor_via_steam_package_flag.dart';
import 'package:maxi_library/src/tools/remote_functionalities_executor/via_stream/remote_functionalities_executor_via_stream_controller.dart';
import 'package:maxi_library/src/tools/remote_functionalities_executor/via_stream/remote_functionalities_executor_via_stream_functions.dart';

class RemoteFunctionalitiesExecutorViaStream with IRemoteFunctionalitiesExecutor, StartableFunctionality, FunctionalityWithLifeCycle {
  final Stream<Map<String, dynamic>> receiver;
  final StreamSink<Map<String, dynamic>> sender;
  final Duration timeout;
  final bool confirmConnection;

  final _waiterSemaphore = Semaphore();
  final _creatorSemaphore = Semaphore();

  Completer<int>? _taskExecutionConfirm;
  Completer<bool>? _waitConfirmConnection;

  bool _senderClose = false;
  int _lastID = 1;

  late RemoteFunctionalitiesExecutorViaStreamFunctions _functionsManager;
  late RemoteFunctionalitiesExecutorViaStreamController _streanManager;

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
      receiver: receiver.where((x) => x.containsKey(packageFlag)),
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

    _functionsManager = joinObject(item: RemoteFunctionalitiesExecutorViaStreamFunctions(mainManager: this));
    _streanManager = joinObject(item: RemoteFunctionalitiesExecutorViaStreamController(mainManager: this));

    joinFuture(sender.done).whenComplete(() {
      _senderClose = true;
      dispose();
    });

    joinEvent(
      event: receiver,
      onData: _onReceivedData,
      onDone: () => dispose(),
    );
    if (confirmConnection) {
      await checkConnection();
    }
  }

  Future<void> checkConnection() async {
    _waitConfirmConnection ??= joinWaiter<bool>();
    bool isGood = false;
    for (int i = 0; i <= (timeout.inMilliseconds ~/ 200); i++) {
      sendPackage(flag: RFESPackageFlag.checkConnection);
      isGood = await _waitConfirmConnection!.future.timeout(const Duration(milliseconds: 200), onTimeout: () => false);
      if (isGood) {
        break;
      }
    }

    if (!isGood) {
      throw NegativeResult(identifier: NegativeResultCodes.timeout, message: const Oration(message: 'The server took too long to confirm your activity'));
    }
  }

  void sendPackage({required RFESPackageFlag flag, Map<String, dynamic> content = const {}}) {
    sender.add({packageFlag: flag.index}..addAll(content));
  }

  @override
  void performObjectDiscard() {
    if (!_senderClose) {
      containErrorLog(detail: const Oration(message: 'Sending close flag'), function: () => sendPackage(flag: RFESPackageFlag.declareClose));
    }
    super.performObjectDiscard();
  }

  Future<int> sendTaskCoordinates({required Future<void> Function(Completer<int>) function}) async {
    await initialize();

    return await _waiterSemaphore.execute(function: () async {
      final waiter = joinWaiter<int>();
      _taskExecutionConfirm = waiter;

      try {
        await function(waiter);
        final id = await waiter.future.timeout(
          timeout,
          onTimeout: () => throw NegativeResult(
            identifier: NegativeResultCodes.timeout,
            message: const Oration(message: 'The server took too long to confirm the execution of the requested task'),
          ),
        );
        return id;
      } finally {
        _taskExecutionConfirm = null;
      }
    });
  }

  @override
  Future<T> executeFunctionality<T, F extends IFunctionality<FutureOr<T>>>({InvocationParameters parameters = InvocationParameters.emptry, String buildName = ''}) async {
    await initialize();
    return await _functionsManager.requestInvocation<T, F>(parameters: parameters, buildName: buildName);
  }

  @override
  StreamStateTexts<T> executeStreamFunctionality<T, F extends IStreamFunctionality<T>>({InvocationParameters parameters = InvocationParameters.emptry, String buildName = ''}) async* {
    await initialize();

    yield* _streanManager.executeStreamFunctionality<T, F>(buildName: buildName, parameters: parameters);
  }

  void _onReceivedData(Map<String, dynamic> data) {
    final rawFlag = data.getRequiredValueWithSpecificType<int>(packageFlag);
    final flag = volatile(detail: const Oration(message: 'Convert number to package flag'), function: () => RFESPackageFlag.values[rawFlag]);

    switch (flag) {
      case RFESPackageFlag.creationObjectResult:
        _processConfirmation(data);
        break;
      case RFESPackageFlag.newFunctionality:
        _creatorSemaphore.execute(function: () => _functionsManager.processNewFunctionality(data));
        break;
      case RFESPackageFlag.newStreamFunctionality:
        _creatorSemaphore.execute(function: () => _streanManager.processNewStreamFunctionality(data));
        break;
      case RFESPackageFlag.functionalityEnded:
        _functionsManager.processFinishedExternalRequest(data);
        break;
      case RFESPackageFlag.checkConnection:
        sendPackage(flag: RFESPackageFlag.confirmConnection);
        break;
      case RFESPackageFlag.confirmConnection:
        _waitConfirmConnection?.completeIfIncomplete(true);
        _waitConfirmConnection = null;
        break;
      case RFESPackageFlag.declareClose:
        sender.close();
        break;
      case RFESPackageFlag.streamSendResult:
        _streanManager.processStreamResult(data);
        break;
      case RFESPackageFlag.streamSendText:
        _streanManager.processStreamText(data);
        break;
      case RFESPackageFlag.streamSendError:
        _streanManager.processStreamError(data);
        break;
      case RFESPackageFlag.streamEnded:
        _streanManager.declareStreamClose(data.getRequiredValueWithSpecificType<int>(identifierFlag));

        break;
      case RFESPackageFlag.cancelStream:
        _streanManager.cancelActiveStream(data.getRequiredValueWithSpecificType<int>(identifierFlag));
        break;
    }
  }

  dynamic serializeResult(result) => volatile(
      detail: const Oration(message: 'Serialize result'),
      function: () {
        if (result == null) {
          return '';
        }
        final type = ConverterUtilities.isPrimitive(result.runtimeType);
        return type == null ? ConverterUtilities.serializeToJson(result) : ConverterUtilities.primitiveClone(result);
      });

  void _processConfirmation(Map<String, dynamic> data) {
    final isCorrect = data.getRequiredValueWithSpecificType<bool>(isCorrectFlag);
    if (isCorrect) {
      final id = data.getRequiredValueWithSpecificType<int>(identifierFlag);
      _taskExecutionConfirm?.completeIfIncomplete(id);
    } else {
      final error = NegativeResult.interpretJson(jsonText: data.getRequiredValueWithSpecificType<String>(contentFlag), checkTypeFlag: true);
      _taskExecutionConfirm?.completeErrorIfIncomplete(error, StackTrace.fromString(error.stackTrace));
    }

    _taskExecutionConfirm = null;
  }

  int getNewID() {
    final id = _lastID;
    _lastID += 1;
    return id;
  }
}
