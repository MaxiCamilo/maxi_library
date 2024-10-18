import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/ithead_connection.dart';
import 'package:maxi_library/src/threads/ithread_invoke_instance.dart';
import 'package:maxi_library/src/threads/messages/request_thread_closure.dart';
import 'package:maxi_library/src/threads/processors/thread_message_processors.dart';
import 'package:maxi_library/src/threads/processors/thread_request_executor.dart';
import 'package:maxi_library/src/threads/processors/thread_request_requester.dart';

class ThreadInvokeInstance with IThreadInvokeInstance {
  final ITheadConnection connection;
  final IThreadManager manager;
  final bool isConnectionServer;

  @override
  Type? entityType;

  int? _threadID;

  final _connectionDone = Completer<IThreadInvokeInstance>();

  late final ThreadRequestExecutor _requestExecutor;
  late final ThreadRequestRequester _requestRequester;
  late final ThreadMessageProcessors _messageProcessors;

  ThreadInvokeInstance({required this.connection, required this.manager, required this.isConnectionServer, this.entityType}) {
    _requestExecutor = ThreadRequestExecutor(manager: manager, messageOutput: connection);
    _requestRequester = ThreadRequestRequester(messageOutput: connection);
    _messageProcessors = ThreadMessageProcessors(
      connection: connection,
      manager: manager,
      requestExecutor: _requestExecutor,
      requestRequester: _requestRequester,
    );

    connection.done.then((_) => closeConnection());
  }

  @override
  Future<IThreadInvokeInstance> get done => _connectionDone.future;

  void _checkIfEntityIsValid(Type type) {
    if (entityType == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: tr('The connection thread is not a service thread, it tried to invoke the service %1', [type]),
      );
    }

    if (type != entityType) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: tr('The connection thread is  a service %1, it tried to invoke the service %2', [entityType, type]),
      );
    }
  }

  void _checkIsActive() {
    if (!connection.isActive) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: tr('The connection is inactive'),
      );
    }
  }

  @override
  Future<R> callEntityFunction<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(T p1, InvocationContext p2) function}) {
    _checkIsActive();
    _checkIfEntityIsValid(T);
    return _requestRequester.callEntityFunction<T, R>(function: function, parameters: parameters);
  }

  @override
  Future<Stream<R>> callEntityStream<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(T p1, InvocationContext p2) function, bool cancelOnError = false}) {
    _checkIsActive();
    _checkIfEntityIsValid(T);
    return _requestRequester.callEntityStream<T, R>(function: function, parameters: parameters);
  }

  @override
  Future<R> callFunctionAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationContext p1) function}) {
    _checkIsActive();
    return _requestRequester.callFunctionAsAnonymous<R>(function: function, parameters: parameters);
  }

  @override
  Future<Stream<R>> callStreamAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(InvocationContext p1) function, bool cancelOnError = false}) {
    _checkIsActive();
    return _requestRequester.callStreamAsAnonymous<R>(function: function, parameters: parameters);
  }

  @override
  void closeConnection() {
    _messageProcessors.close();
    _requestRequester.close();
    _requestExecutor.close();

    if (!_connectionDone.isCompleted) {
      _connectionDone.complete(this);
    }

    connection.close();
  }

  @override
  void requestEndOfThread() {
    if (isConnectionServer) {
      log('[ThreadInvokeInstance] This is a server connection, it cannot be terminated!');
      return;
    }

    if (connection.isActive) {
      connection.sendMessage(message: RequestThreadClosure());
    }
  }

  @override
  Future<int> getThreadID() async {
    if (_threadID != null) {
      return _threadID!;
    }

    _threadID = await callFunctionAsAnonymous(function: (x) async => x.thread.threadID);
    return _threadID!;
  }

  @override
  void defineThreadID(int id) {
    _threadID = id;
  }

  @override
  Future<ThreadPipe<R, S>> connectWithBroadcastPipe<R, S>({InvocationParameters parameters = InvocationParameters.emptry, required Future<BroadcastPipe<R, S>> Function(InvocationContext p1) function}) {
    final newParameters = InvocationParameters.clone(parameters, avoidConstants: false);
    newParameters.namedParameters['#FUNCTION#'] = function;
    return callFunctionAsAnonymous(function: _connectWithBroadcastPipe<R, S>, parameters: parameters);
  }

  static Future<ThreadPipe<R, S>> _connectWithBroadcastPipe<R, S>(InvocationContext parameters) async {
    final function = parameters.named<Future<BroadcastPipe<R, S>> Function(InvocationContext)>('#FUNCTION#');
    final broadcast = await function(parameters);
    await broadcast.initialize();

    return broadcast.makePipe();
  }

  @override
  Future<ThreadPipe<R, S>> connectWithEntityBroadcastPipe<T, R, S>({InvocationParameters parameters = InvocationParameters.emptry, required Future<BroadcastPipe<R, S>> Function(T p1, InvocationContext p2) function}) {
    final newParameters = InvocationParameters.clone(parameters, avoidConstants: false);
    newParameters.namedParameters['#FUNCTION#'] = function;
    return callEntityFunction<T, ThreadPipe<R, S>>(function: _connectWithEntityBroadcastPipe<T, R, S>, parameters: parameters);
  }

  static Future<ThreadPipe<R, S>> _connectWithEntityBroadcastPipe<T, R, S>(T entity, InvocationContext parameters) async {
    final function = parameters.named<Future<BroadcastPipe<R, S>> Function(T, InvocationContext)>('#FUNCTION#');
    final broadcast = await function(entity, parameters);
    await broadcast.initialize();

    return broadcast.makePipe();
  }
}
