import 'dart:async';
import 'dart:isolate';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/isolates/isolated_thread_pipeline_manager.dart';
import 'package:maxi_library/src/threads/isolates/isolated_thread_stream_manager.dart';
import 'package:maxi_library/src/threads/isolates/ithread_isolador.dart';
import 'package:maxi_library/src/threads/isolates/thread_isolator_client.dart';
import 'package:maxi_library/src/threads/isolates/thread_isolator_server.dart';
import 'package:maxi_library/src/threads/ithread_message.dart';
import 'package:maxi_library/src/threads/standars/thread_function_requester.dart';
import 'package:maxi_library/src/threads/standars/thread_message_executor.dart';
import 'package:maxi_library/src/threads/standars/thread_messages_processor.dart';

class ThreadIsolatorServerConnection with IThreadInvoker, IThreadInvokeInstance, IThreadIsolador {
  final ThreadIsolatorServer server;
  final ChannelIsolates channel;

  final _doneCompleter = Completer<IThreadInvokeInstance>();

  late final ThreadMessagesProcessor messageProcessor;
  late final ThreadMessageExecutor externalFunctionExecutor;
  late final ThreadFunctionRequester externalFunctionalRequester;

  @override
  late final IsolatedThreadStreamManager streamManager;

  @override
  IsolatedThreadPipelineManager get pipelineManager => server.pipelineManager;

  @override
  final int threadID;

  Type? _entityType;

  @override
  bool get isServer => true;

  @override
  Type? get entityType => _entityType;

  @override
  Future<IThreadInvokeInstance> get done => _doneCompleter.future;

  ThreadIsolatorServerConnection({required this.server, required this.channel, required this.threadID, Type? entityTye}) {
    _entityType = entityTye;

    channel.done.whenComplete(closeConnection);

    streamManager = IsolatedThreadStreamManager(manager: this);

    externalFunctionExecutor = ThreadMessageExecutor(
      thread: server,
      sender: this,
      senderMessage: channel.createConverter<IThreadMessage>(),
    );

    externalFunctionalRequester = ThreadFunctionRequester(
      sender: this,
      senderMessage: channel.createConverter<IThreadMessage>(),
      thread: server,
    );

    messageProcessor = ThreadMessagesProcessor(
      thread: server,
      sender: this,
      streamMessage: channel.stream.whereType<IThreadMessage>(),
      executor: externalFunctionExecutor,
      requester: externalFunctionalRequester,
    );
  }

  void changeEntityType(Type type) => _entityType = type;

  @override
  Future<void> setEntity(newEnity) async {
    await callFunction(parameters: InvocationParameters.only(newEnity), function: _setEntityInThread);
    _entityType = newEnity;
  }

  static Future<void> _setEntityInThread(InvocationContext context) {
    return context.thread.setEntity(context.firts());
  }

  @override
  Future<T?> getEntity<T extends Object>() async {
    final entity = await callFunction(parameters: InvocationParameters.emptry, function: _getEntityInThread<T>);
    if (entity == null) {
      _entityType = null;
    } else if (entity.runtimeType != _entityType) {
      _entityType = entity.runtimeType;
    }

    return entity;
  }

  static Future<T?> _getEntityInThread<T extends Object>(InvocationContext context) {
    return context.thread.getEntity<T>();
  }

  @override
  Future<IThreadInvokeInstance?> getEntityInstance<T extends Object>() {
    return server.getEntityInstance<T>();
  }

  @override
  Future<IThreadInvokeInstance?> getIDInstance({required int id}) {
    return server.getIDInstance(id: id);
  }

  @override
  Future<IThreadInvokeInstance> mountEntity<T extends Object>({required T entity, bool ifExistsOmit = true}) {
    return server.mountEntity<T>(entity: entity, ifExistsOmit: ifExistsOmit);
  }

  @override
  Future<R> callBackgroundFunction<R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(InvocationContext para) function}) {
    return server.callBackgroundFunction<R>(function: function, parameters: parameters);
  }

  @override
  Future<R> callEntityFunction<T extends Object, R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(T p1, InvocationContext p2) function}) {
    if (T == _entityType) {
      parameters = InvocationParameters.clone(parameters)..namedParameters['#_E()_#'] = function;
      return callFunction(parameters: parameters, function: _callEntityFunctionInThread<T, R>);
    }
    return server.callEntityFunction<T, R>(function: function, parameters: parameters);
  }

  static Future<R> _callEntityFunctionInThread<T extends Object, R>(InvocationContext context) async {
    final function = context.named<Future<R> Function(T, InvocationContext)>('#_E()_#');

    final entity = await volatileAsync<T>(detail: tr('Thread does not handle entity of type %1', [T]), function: () async => (await context.thread.getEntity<T>()) as T);
    return function(entity, context);
  }

  @override
  Future<Stream<R>> callEntityStream<T extends Object, R>(
      {InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<Stream<R>> Function(T p1, InvocationContext p2) function, bool cancelOnError = false}) async {
    if (T == _entityType) {
      return streamManager.createSharedStreamOnEntity(parameters: parameters, function: function, invoker: this);
    }
    return server.callEntityStream<T, R>(function: function, parameters: parameters);
  }

  @override
  Future<R> callFunction<R>({required InvocationParameters parameters, required FutureOr<R> Function(InvocationContext p1) function}) async {
    return externalFunctionalRequester.executeFunction<R>(parameters: parameters, function: function);
  }

  @override
  Future<R> callFunctionOnTheServer<R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(InvocationContext p1) function}) async {
    return function(InvocationContext.fromParametes(thread: server, applicant: this, parametres: parameters));
  }

  @override
  Future<Stream<R>> callStream<R>({required InvocationParameters parameters, required FutureOr<Stream<R>> Function(InvocationContext p1) function, bool cancelOnError = false}) {
    return streamManager.createSharedStream(parameters: parameters, function: function, invoker: this);
  }

  @override
  void requestEndOfThread() {
    callFunction(
      parameters: InvocationParameters.emptry,
      function: (x) async => x.thread.closeThread(),
    ).whenComplete(() => declareClosed());
  }

  @override
  void closeConnection() {
    scheduleMicrotask(() async {
      if (!channel.isActive) {
        return;
      }
      await callFunction(
          parameters: InvocationParameters.emptry,
          function: (x) async {
            final connection = x.sender as IThreadInvokeInstance;
            connection.declareClosed();
          });
      declareClosed();
    });
  }

  Future<SendPort> getConnectionSendPort() {
    return callFunction(parameters: InvocationParameters.emptry, function: _getConnectionSendPortOnThread);
  }

  static Future<SendPort> _getConnectionSendPortOnThread(InvocationContext context) async {
    final client = volatile(detail: tr('Thread is not ThreadIsolatorClient'), function: () => context.thread as ThreadIsolatorClient);

    return client.getConnectionSendPort();
  }

  @override
  void declareClosed() {
    channel.close();

    messageProcessor.close();
    externalFunctionExecutor.close();
    externalFunctionalRequester.close();
    _doneCompleter.completeIfIncomplete(this);
    streamManager.close();
  }

  @override
  Future<IPipe<S, R>> createEntityPipe<T extends Object, R, S>({
    InvocationParameters parameters = InvocationParameters.emptry,
    required FutureOr<void> Function(T p1, InvocationContext p2, IPipe<R, S> p3) function,
  }) {
    if (T == entityType) {
      return server.pipelineManager.createEntityPipeline(parameters: parameters, function: function, sender: this);
    } else {
      return server.createEntityPipe<T, R, S>(function: function, parameters: parameters);
    }
  }

  @override
  Future<IPipe<S, R>> createPipe<R, S>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<void> Function(InvocationContext p1, IPipe<R, S> p2) function}) {
    return server.pipelineManager.createPipeline(parameters: parameters, function: function, sender: this);
  }
}
