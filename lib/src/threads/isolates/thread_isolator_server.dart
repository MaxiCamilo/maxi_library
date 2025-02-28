import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/isolates/isolate_initializer.dart';
import 'package:maxi_library/src/threads/isolates/isolate_thread_channel_manager.dart';
import 'package:maxi_library/src/threads/isolates/isolated_thread_stream_manager.dart';
import 'package:maxi_library/src/threads/isolates/ithread_isolador.dart';
import 'package:maxi_library/src/threads/isolates/thread_isolator_background_manager.dart';
import 'package:maxi_library/src/threads/isolates/thread_isolator_server_connection.dart';

class ThreadIsolatorServer with IThreadInvoker, IThreadManager, IThreadManagerServer, IThreadIsolador {
  @override
  Type? get entityType => null;

  @override
  bool get isServer => true;

  @override
  int get threadID => 0;

  int _lasiId = 1;

  final _initializerList = <IThreadInitializer>[];
  final _clientList = <ThreadIsolatorServerConnection>[];

  @override
  late final IsolateThreadChannelManager channelsManager;

  @override
  late final IsolatedThreadStreamManager streamManager;

  late final ThreadIsolatorBackgroundManager backgroundManager;

  ThreadIsolatorServer() {
    channelsManager = IsolateThreadChannelManager(thread: this);
    streamManager = IsolatedThreadStreamManager(manager: this);
    backgroundManager = ThreadIsolatorBackgroundManager(manager: this);
  }

  @override
  Future<void> setEntity(newEnity) {
    throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: Oration(message: 'This is a server thread, cannot define an entity in it'));
  }

  @override
  void addThreadInitializer({required IThreadInitializer initializer}) {
    if (!_initializerList.contains(initializer)) {
      _initializerList.add(initializer);
    }
  }

  @override
  Future<R> callBackgroundFunction<R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(InvocationContext para) function}) {
    return backgroundManager.callBackgroundFunction<R>(function: function, parameters: parameters);
  }

  @override
  Future<Stream<R>> callBackgroundStream<R>({required InvocationParameters parameters, required FutureOr<Stream<R>> Function(InvocationContext p1) function}) {
    return backgroundManager.callBackgroundStream<R>(function: function, parameters: parameters);
  }

  @override
  Future<R> callEntityFunction<T extends Object, R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(T p1, InvocationContext p2) function}) {
    final connector = _clientList.selectItem((x) => x.entityType == T);

    if (connector == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: Oration(message: 'There is no thread that manages the entity %1', textParts: [T]),
      );
    }

    return connector.callEntityFunction<T, R>(function: function, parameters: parameters);
  }

  @override
  Future<Stream<R>> callEntityStream<T extends Object, R>(
      {InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<Stream<R>> Function(T p1, InvocationContext p2) function, bool cancelOnError = false}) {
    final connector = _clientList.selectItem((x) => x.entityType == T);

    if (connector == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: Oration(message: 'There is no thread that manages the entity %1', textParts: [T]),
      );
    }

    return connector.callEntityStream<T, R>(function: function, parameters: parameters);
  }

  @override
  Future<R> callFunctionOnTheServer<R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(InvocationContext p1) function}) async {
    return await function(InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters));
  }

  @override
  void closeThread() {
    log('[ThreadIsolatorServer] This is a server thread, it cannot be closed');
  }

  @override
  Future<R> callFunction<R>({required InvocationParameters parameters, required FutureOr<R> Function(InvocationContext p1) function}) async {
    return await function(InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters));
  }

  @override
  Future<Stream<R>> callStream<R>({required InvocationParameters parameters, required FutureOr<Stream<R>> Function(InvocationContext p1) function, bool cancelOnError = false}) async {
    return await function(InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters));
  }

  @override
  Future<T?> getEntity<T extends Object>() async {
    final connector = await getEntityInstance<T>();
    if (connector == null) {
      return null;
    }

    return await connector.getEntity<T>();
  }

  @override
  Future<ThreadIsolatorServerConnection?> getEntityInstance<T extends Object>() async {
    return _clientList.selectItem((x) => x.entityType == T);
  }

  @override
  Future<ThreadIsolatorServerConnection?> getIDInstance({required int id}) async {
    return _clientList.selectItem((x) => x.threadID == id);
  }

  @override
  Future<ThreadIsolatorServerConnection> makeNewThread({required List<IThreadInitializer> initializers, required String name}) async {
    final creator = IsolateInitializer(initializers: [..._initializerList, ...initializers]);
    final id = _lasiId;
    _lasiId += 1;

    final (isolate, channel) = await creator.mountIsolate(name: name, threadID: id);
    final newConntection = ThreadIsolatorServerConnection(channel: channel, server: this, threadID: id, entityTye: null, isolate: isolate);

    newConntection.done.then(_closeConnection);

    _clientList.add(newConntection);
    return newConntection;
  }

  @override
  Future<ThreadIsolatorServerConnection> mountEntity<T extends Object>({required T entity, bool ifExistsOmit = true}) async {
    final actualConnection = _clientList.selectItem((x) => x.entityType == T);

    if (actualConnection != null) {
      if (ifExistsOmit) {
        return actualConnection;
      } else {
        throw NegativeResult(identifier: NegativeResultCodes.contextInvalidFunctionality, message: Oration(message: 'Thread with entity %1 has already been mounted', textParts: [T]));
      }
    }

    final name = entity is IThreadService ? entity.serviceName : entity.runtimeType.toString();
    final newConntection = await makeNewThread(initializers: [], name: name);
    newConntection.changeEntityType(T);

    try {
      await newConntection.callFunction(parameters: InvocationParameters.only(entity), function: _initializeEntityInThread<T>);
    } catch (_) {
      newConntection.requestEndOfThread();
      rethrow;
    }

    return newConntection;
  }

  static Future<void> _initializeEntityInThread<T>(InvocationContext context) {
    return context.thread.setEntity(context.firts<T>());
  }

  void _closeConnection(IThreadInvokeInstance value) {
    _clientList.remove(value);
  }
/*
  @override
  Future<IPipe<S, R>> createEntityPipe<T extends Object, R, S>({
    InvocationParameters parameters = InvocationParameters.emptry,
    required FutureOr<void> Function(T p1, InvocationContext p2, IPipe<R, S> p3) function,
  }) async {
    final connector = _clientList.selectItem((x) => x.entityType == T);

    if (connector == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: Oration(message: 'There is no thread that manages the entity %1', textParts: [T]),
      );
    }

    return pipelineManager.createEntityPipeline<T, R, S>(parameters: parameters, function: function, sender: connector);
  }

  @override
  Future<IPipe<S, R>> createPipe<R, S>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<void> Function(InvocationContext, IPipe<R, S>) function}) async {
    final pipe = FakePipe<R, S>();
    return pipe.callFunction(parameters: InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters), function: function);
  }*/

  @override
  Future<void> closeAllThread() async {
    for (final item in _clientList) {
      item.requestEndOfThread();
    }

    _lasiId = 1;
  }

  @override
  void killAllThread() {
    for (final item in _clientList) {
      item.killIsolates();
    }

    _clientList.clear();

    _lasiId = 1;
  }

  @override
  Future<IChannel<S, R>> createChannel<R, S>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<void> Function(InvocationContext context, IChannel<R, S> channel) function}) async {
    final master = MasterChannel<R, S>(closeIfEveryoneClosed: true);

    scheduleMicrotask(() async {
      try {
        await function(InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters), master);
      } catch (ex, st) {
        master.addErrorIfActive(ex, st);
        master.close();
      }
    });

    return master.createSlave();
  }

  @override
  Future<IChannel<S, R>> createEntityChannel<T extends Object, R, S>(
      {InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<void> Function(T entity, InvocationContext context, IChannel<R, S> channel) function}) async {
    final connector = _clientList.selectItem((x) => x.entityType == T);

    if (connector == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: Oration(message: 'There is no thread that manages the entity %1', textParts: [T]),
      );
    }

    return connector.createEntityChannel<T, R, S>(function: function, parameters: parameters);
  }
}
