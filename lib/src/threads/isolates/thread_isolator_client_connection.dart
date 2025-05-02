import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/isolates/isolate_thread_channel_manager.dart';
import 'package:maxi_library/src/threads/isolates/isolated_thread_stream_manager.dart';
import 'package:maxi_library/src/threads/isolates/ithread_isolador.dart';
import 'package:maxi_library/src/threads/isolates/thread_isolator_client.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_message.dart';
import 'package:maxi_library/src/threads/standars/thread_function_requester.dart';
import 'package:maxi_library/src/threads/standars/thread_message_executor.dart';
import 'package:maxi_library/src/threads/standars/thread_messages_processor.dart';

class ThreadIsolatorClientConnection with IThreadInvoker, IThreadInvokeInstance, IThreadIsolador {
  final ThreadIsolatorClient clientMannager;
  final ChannelIsolates channel;

  @override
  int threadID;

  @override
  Type? entityType;

  final _doneCompleter = MaxiCompleter<ThreadIsolatorClientConnection>();
  final _initializeCompleter = MaxiCompleter<ThreadIsolatorClientConnection>();

  late final ThreadMessagesProcessor messageProcessor;
  late final ThreadMessageExecutor externalFunctionExecutor;
  late final ThreadFunctionRequester externalFunctionalRequester;

  @override
  late final IsolatedThreadStreamManager streamManager;

  @override
  late final IsolateThreadChannelManager channelsManager;

  Future<ThreadIsolatorClientConnection> get onInitialize => _initializeCompleter.future;

  @override
  bool get isServer => false;

  @override
  Future<IThreadInvokeInstance> get done => _doneCompleter.future;

  ThreadIsolatorClientConnection({required this.clientMannager, required this.channel, required this.threadID}) {
    streamManager = IsolatedThreadStreamManager(manager: this);
    channelsManager = IsolateThreadChannelManager(thread: this);

    externalFunctionExecutor = ThreadMessageExecutor(
      thread: clientMannager,
      sender: this,
      senderMessage: channel.createConverter<IThreadMessage>(),
    );

    externalFunctionalRequester = ThreadFunctionRequester(
      sender: this,
      senderMessage: channel.createConverter<IThreadMessage>(),
      thread: clientMannager,
    );

    messageProcessor = ThreadMessagesProcessor(
      thread: clientMannager,
      sender: this,
      streamMessage: channel.receiver.whereType<IThreadMessage>(),
      executor: externalFunctionExecutor,
      requester: externalFunctionalRequester,
    );
  }

  void initialize({required int threadID, required Type? entityType}) {
    this.threadID = threadID;
    this.entityType = entityType;

    _initializeCompleter.completeIfIncomplete(this);
  }

  @override
  Future<R> callBackgroundFunction<R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(InvocationContext para) function}) {
    return clientMannager.callBackgroundFunction<R>(parameters: parameters, function: function);
  }

  @override
  Future<Stream<R>> callBackgroundStream<R>({required InvocationParameters parameters, required FutureOr<Stream<R>> Function(InvocationContext p1) function}) {
    return clientMannager.callBackgroundStream<R>(parameters: parameters, function: function);
  }

  @override
  Future<IChannel<S, R>> callBackgroundChannel<R, S>({required InvocationParameters parameters, required FutureOr<void> Function(InvocationContext context, IChannel<R, S> channel) function}) {
    return clientMannager.callBackgroundChannel<R, S>(parameters: parameters, function: function);
  }

  @override
  Future<R> callEntityFunction<T extends Object, R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(T p1, InvocationContext p2) function}) {
    if (entityType == T) {
      parameters = InvocationParameters.clone(parameters)..namedParameters['#_CE()_#'] = function;
      return externalFunctionalRequester.executeFunction(parameters: parameters, function: _callEntityFunction<T, R>);
    }
    if (clientMannager.entityType == T) {
      return clientMannager.callEntityFunction<T, R>(function: function, parameters: parameters);
    }

    return clientMannager.callEntityFunction<T, R>(parameters: parameters, function: function);
  }

  static Future<R> _callEntityFunction<T extends Object, R>(InvocationContext context) async {
    final function = context.named<FutureOr<R> Function(T, InvocationContext)>('#_CE()_#');
    final entity = await volatileAsync(detail: Oration(message: 'Thread entity is null!'), function: () async => (await context.thread.getEntity<T>()) as T);

    return await function(entity, context);
  }

  @override
  Future<Stream<R>> callEntityStream<T extends Object, R>(
      {InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<Stream<R>> Function(T p1, InvocationContext p2) function, bool cancelOnError = false}) {
    if (entityType == T) {
      return streamManager.createSharedStreamOnEntity<T, R>(parameters: parameters, function: function, invoker: this);
    }
    if (clientMannager.entityType == T) {
      return streamManager.createSharedStreamOnEntity<T, R>(parameters: parameters, function: function, invoker: this);
    }

    return clientMannager.callEntityStream<T, R>(parameters: parameters, function: function);
  }

  @override
  Future<R> callFunction<R>({required InvocationParameters parameters, required FutureOr<R> Function(InvocationContext p1) function}) {
    return externalFunctionalRequester.executeFunction<R>(parameters: parameters, function: function);
  }

  @override
  Future<R> callFunctionOnTheServer<R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(InvocationContext p1) function}) {
    return clientMannager.callFunctionOnTheServer(function: function, parameters: parameters);
  }

  @override
  Future<Stream<R>> callStreamOnTheServer<R>({required InvocationParameters parameters, required FutureOr<Stream<R>> Function(InvocationContext p1) function}) {
    return clientMannager.callStreamOnTheServer(function: function, parameters: parameters);
  }

  @override
  Future<Stream<R>> callStream<R>({required InvocationParameters parameters, required FutureOr<Stream<R>> Function(InvocationContext p1) function, bool cancelOnError = false}) {
    return streamManager.createSharedStream(parameters: parameters, function: function, invoker: this);
  }

  @override
  Future<T?> getEntity<T extends Object>() {
    return clientMannager.callFunction(parameters: InvocationParameters.emptry, function: (x) => x.thread.getEntity<T>());
  }

  @override
  Future<IThreadInvokeInstance?> getEntityInstance<T extends Object>() async {
    if (entityType == T) {
      return this;
    }

    return clientMannager.getEntityInstance<T>();
  }

  @override
  Future<IThreadInvokeInstance?> getIDInstance({required int id}) async {
    if (threadID == id) {
      return this;
    }

    return clientMannager.getIDInstance(id: id);
  }

  @override
  Future<IThreadInvokeInstance> mountEntity<T extends Object>({required T entity, bool ifExistsOmit = true}) {
    return clientMannager.mountEntity<T>(entity: entity, ifExistsOmit: ifExistsOmit);
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
    maxiScheduleMicrotask(() async {
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

  @override
  Future<void> setEntity(newEnity) {
    return clientMannager.setEntity(newEnity);
  }

  @override
  void declareClosed() {
    channel.close();

    messageProcessor.close();
    externalFunctionExecutor.close();
    externalFunctionalRequester.close();
    streamManager.close();
    channelsManager.closeAll();
    _doneCompleter.completeIfIncomplete(this);
  }

  @override
  Future<IChannel<S, R>> createChannel<R, S>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<void> Function(InvocationContext context, IChannel<R, S> channel) function}) async {
    return channelsManager.createExternalChannel<R, S>(parameters: parameters, function: function);
  }

  @override
  Future<IChannel<S, R>> createEntityChannel<T extends Object, R, S>(
      {InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<void> Function(T entity, InvocationContext context, IChannel<R, S> channel) function}) {
    parameters = InvocationParameters.clone(parameters)..namedParameters['_#FCH()"_'] = function;
    return channelsManager.createExternalChannel<R, S>(parameters: parameters, function: _executeEntityChannel<T, R, S>);
  }

  static Future<void> _executeEntityChannel<T extends Object, R, S>(InvocationContext context, IChannel<R, S> channel) async {
    final funcion = context.named<FutureOr<void> Function(T, InvocationContext, IChannel<R, S>)>('_#FCH()"_');
    final entity = await volatileAsync(detail: Oration(message: 'Thread entity is null!'), function: () async => (await context.thread.getEntity<T>()) as T);

    return await funcion(entity, context, channel);
  }
}
// final funcion = context.named<FutureOr<void> Function(T, InvocationContext, IChannel<R, S>)>('_#FCH()"_');
