import 'dart:async';
import 'dart:isolate';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/iexternal_thread_stream_processor.dart';
import 'package:maxi_library/src/threads/isolates/isolate_thread_pipe_processor.dart';
import 'package:maxi_library/src/threads/isolates/isolate_thread_connection.dart';
import 'package:maxi_library/src/threads/isolates/isolated_thread_server.dart';
import 'package:maxi_library/src/threads/ithread_invoke_instance.dart';
import 'package:maxi_library/src/threads/processors/thread_invoke_instance.dart';

class IsolatedThreadClient with IThreadInvoker, IThreadManager, IThreadManagerClient {
  @override
  late final IThreadInvokeInstance serverConnection;

  @override
  final int threadID;

  @override
  dynamic entity;

  @override
  final connectionWithServices = <Type, IThreadInvokeInstance>{};

  @override
  final connections = <IThreadInvokeInstance>[];

  @override
  final ThreadPipeProcessor pipeProcessor = IsolateThreadPipeProcessor();

  final externalConnections = <IThreadInvokeInstance>[];

  final _tipOrderSynchronizer = Semaphore();

  IsolatedThreadClient({required ChannelIsolates channel, required this.threadID}) {
    final serverPort = IsolateThreadConnection(channel: channel);
    serverConnection = ThreadInvokeInstance(connection: serverPort, manager: this, isConnectionServer: true);
    serverConnection.defineThreadID(0); //<--- Server connections are always 0
  }

  bool _isTheEntity<T>() {
    checkProgrammingFailure(thatChecks: tr('Type Entity %1 is not dynamic', [T]), result: () => T != dynamic);
    return entity != null && entity.runtimeType == T;
  }

  @override
  Future<R> callEntityFunction<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(T p1, InvocationContext p2) function}) async {
    if (_isTheEntity<T>()) {
      return function(entity as T, InvocationContext.fromParametes(thread: this, parametres: parameters));
    }

    final connection = await requestConnectionForService<T>();
    return await connection.callEntityFunction<T, R>(parameters: parameters, function: function);
  }

  @override
  Future<Stream<R>> callEntityStream<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(T p1, InvocationContext p2) function, bool cancelOnError = false}) async {
    if (_isTheEntity<T>()) {
      return function(entity as T, InvocationContext.fromParametes(thread: this, parametres: parameters));
    }

    final connection = await requestConnectionForService<T>();
    return await connection.callEntityStream<T, R>(parameters: parameters, function: function);
  }

  @override
  Future<R> callFunctionOnTheServer<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationContext p1) function}) async {
    return serverConnection.callFunctionAsAnonymous<R>(function: function, parameters: parameters);
  }

  @override
  Future<R> callFunctionAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationContext p1) function}) {
    return function(InvocationContext.fromParametes(thread: this, parametres: parameters));
  }

  @override
  Future<Stream<R>> callStreamAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(InvocationContext p1) function, bool cancelOnError = false}) {
    return function(InvocationContext.fromParametes(thread: this, parametres: parameters));
  }

  @override
  Future<IThreadInvokeInstance> mountEntity<T extends Object>({required T entity, bool ifExistsOmit = true}) async {
    checkProgrammingFailure(thatChecks: tr('It is not the same type of entity'), result: () => !_isTheEntity<T>());
    await callFunctionOnTheServer(function: _mountEntityInServer<T>, parameters: InvocationParameters.list([entity, ifExistsOmit]));
    return await requestConnectionForService<T>();
  }

  static Future<void> _mountEntityInServer<T extends Object>(InvocationContext parameters) async {
    final entity = parameters.firts<T>();
    final ifExistsOmit = parameters.second<bool>();

    final server = parameters.thread as IThreadManagerServer;
    await server.mountEntity<T>(entity: entity, ifExistsOmit: ifExistsOmit);
  }

  @override
  Future<IThreadInvokeInstance> requestConnectionForService<T>() async {
    checkProgrammingFailure(thatChecks: tr('It is not the same type of entity'), result: () => !_isTheEntity<T>());
    final existing = connectionWithServices[T];

    if (existing != null) {
      return existing;
    }

    return await _tipOrderSynchronizer.execute(function: () async {
      final existing = connectionWithServices[T];
      if (existing != null) {
        return existing;
      }

      final sendPort = await callFunctionOnTheServer(function: _requestTipForService<T>);
      final newChannel = ChannelIsolates.createDestinationChannel(sendSender: true, sender: sendPort);
      final newConnection = IsolateThreadConnection(channel: newChannel);
      final newInvoker = ThreadInvokeInstance(connection: newConnection, isConnectionServer: false, manager: this, entityType: T);

      connections.add(newInvoker);
      connectionWithServices[T] = newInvoker;

      newInvoker.done.then(_reactConnectionClose);

      return newInvoker;
    });
  }

  static Future<SendPort> _requestTipForService<T>(InvocationContext parameters) async {
    final server = parameters.thread as IsolatedThreadServer;
    return await server.getRawConnectionAccordingToEntity<T>();
  }

  static Future<SendPort> _requestTipForID(InvocationContext parameters) async {
    final server = parameters.thread as IsolatedThreadServer;
    final id = parameters.firts<int>();
    return await server.getRawConnectionAccordingToID(id);
  }

  FutureOr<void> _reactConnectionClose(IThreadInvokeInstance connection) {
    connections.remove(connection);
    externalConnections.remove(connection);
    connectionWithServices.removeWhere((_, x) => x == connection);
  }

  @override
  void closeThread() {
    for (final item in externalConnections) {
      item.closeConnection();
    }

    for (final item in connections) {
      item.closeConnection();
    }

    connections.clear();
    serverConnection.closeConnection();

    Future.delayed(Duration(milliseconds: 20)).whenComplete(() {
      containErrorLog(
        detail: tr('[IsolateInitializer] FAILED!: The negative result cannot be sent to the other isolator.'),
        function: () => Isolate.exit(),
      );
    });
  }

  @override
  Future<void> defineAsService({required Object newEntity}) async {
    checkProgrammingFailure(thatChecks: tr('The thread was not previously initialized with an entity'), result: () => entity == null);

    entity = newEntity;

    if (entity is StartableFunctionality) {
      try {
        await (entity as StartableFunctionality).initialize();
      } catch (_) {
        entity = null;
        rethrow;
      }
    }
  }

  @override
  Future<SendPort> getConnectionTip() async {
    final newTip = ChannelIsolates.createInitialChannelManually();

    final uninitializedConnection = IsolateThreadConnection(channel: newTip);
    final newConnection = ThreadInvokeInstance(connection: uninitializedConnection, manager: this, isConnectionServer: false);

    externalConnections.add(newConnection);

    newConnection.done.then(_reactConnectionClose);

    return newTip.serder;
  }

  @override
  Future<IThreadInvokeInstance> locateConnection(int id) async {
    if (id == 0) {
      return serverConnection;
    }

    for (final conn in [...externalConnections, ...connections]) {
      if ((await conn.getThreadID()) == id) {
        return conn;
      }
    }

    return await _tipOrderSynchronizer.execute(function: () async {
      for (final conn in [...externalConnections, ...connections]) {
        if ((await conn.getThreadID()) == id) {
          return conn;
        }
      }

      final sendPort = await callFunctionOnTheServer(function: _requestTipForID, parameters: InvocationParameters.only(id));
      final newChannel = ChannelIsolates.createDestinationChannel(sendSender: true, sender: sendPort);
      final newConnection = IsolateThreadConnection(channel: newChannel);
      final newInvoker = ThreadInvokeInstance(connection: newConnection, isConnectionServer: false, manager: this, entityType: null);

      connections.add(newInvoker);
      newInvoker.done.then(_reactConnectionClose);

      return newInvoker;
    });
  }

  @override
  Future<R> callBackgroundFunction<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationContext para) function}) {
    final parametersClone = InvocationParameters.clone(parameters, avoidConstants: false);
    parametersClone.namedParameters['#FUNCTION#'] = function;

    return callFunctionOnTheServer<R>(parameters: parametersClone, function: _callBackgroundFunctionOnServer<R>);
  }

  static Future<R> _callBackgroundFunctionOnServer<R>(InvocationParameters parameters) {
    final function = parameters.named<Future<R> Function(InvocationContext)>('#FUNCTION#');

    return ThreadManager.instance.callBackgroundFunction(function: function, parameters: InvocationParameters.clone(parameters));
  }

  @override
  Future<ThreadPipe<R, S>> connectWithEntityBroadcastPipe<T, R, S>(
      {InvocationParameters parameters = InvocationParameters.emptry, required Future<BroadcastPipe<R, S>> Function(T p1, InvocationContext p2) function}) async {
    if (_isTheEntity<T>()) {
      final broadcats = await function(entity as T, InvocationContext.fromParametes(thread: this, parametres: parameters));
      await broadcats.initialize();
      return broadcats.makePipe();
    }

    final connection = await requestConnectionForService<T>();
    return connection.connectWithEntityBroadcastPipe<T, R, S>(function: function, parameters: parameters);
  }
}
