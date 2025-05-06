import 'dart:async';
import 'dart:isolate';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/isolates/isolate_thread_channel_manager.dart';
import 'package:maxi_library/src/threads/isolates/isolated_thread_stream_manager.dart';
import 'package:maxi_library/src/threads/isolates/ithread_isolador.dart';
import 'package:maxi_library/src/threads/isolates/thread_isolator_client_connection.dart';
import 'package:maxi_library/src/threads/isolates/thread_isolator_server.dart';

class ThreadIsolatorClient with IThreadInvoker, IThreadManager, IThreadManagerClient, IThreadIsolador {
  final _connectionstList = <IThreadInvokeInstance>[];
  dynamic _entity;

  late final IThreadInvokeInstance _serverConnection;

  @override
  int threadID;

  @override
  Type? get entityType => _entity?.runtimeType;

  @override
  bool get isServer => false;

  @override
  late final IsolateThreadChannelManager channelsManager;

  @override
  late final IsolatedThreadStreamManager streamManager;

  @override
  IThreadInvokeInstance get serverConnection => _serverConnection;

  ThreadIsolatorClient({required this.threadID, required ChannelIsolates serverChannel}) {
    _serverConnection = ThreadIsolatorClientConnection(clientMannager: this, channel: serverChannel, threadID: 0);
    (_serverConnection as ThreadIsolatorClientConnection).initialize(threadID: 0, entityType: null);
    channelsManager = IsolateThreadChannelManager(thread: this);
    streamManager = IsolatedThreadStreamManager(manager: this);
  }

  @override
  Future<void> setEntity(newEnity) async {
    if (newEnity is StartableFunctionality) {
      await newEnity.initialize();
    }

    _entity = newEnity;
  }

  @override
  Future<T?> getEntity<T extends Object>() async {
    if (_entity == null) {
      return null;
    }

    return volatile(
      detail: Oration(message: 'Thread %1 does not handle entity %2, it handles entity %3', textParts: [threadID, T, _entity.runtimeType]),
      function: () => _entity as T,
    );
  }

  @override
  Future<R> callBackgroundFunction<R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(InvocationContext para) function}) {
    final newParameters = InvocationParameters.list([function, parameters]);
    return _serverConnection.callFunction(parameters: newParameters, function: _callBackgroundFunction<R>);
  }

  static Future<R> _callBackgroundFunction<R>(InvocationParameters parameters) {
    final function = parameters.firts<FutureOr<R> Function(InvocationContext)>();
    final functionParameters = parameters.second<InvocationParameters>();

    return ThreadManager.callBackgroundFunction(function: function, parameters: functionParameters);
  }

  @override
  Future<Stream<R>> callBackgroundStream<R>({required InvocationParameters parameters, required FutureOr<Stream<R>> Function(InvocationContext p1) function}) {
    final newParameters = InvocationParameters.list([function, parameters]);
    return _serverConnection.callStream(parameters: newParameters, function: _callBackgroundStream<R>);
  }

  static Future<Stream<R>> _callBackgroundStream<R>(InvocationParameters parameters) {
    final function = parameters.firts<FutureOr<Stream<R>> Function(InvocationContext)>();
    final functionParameters = parameters.second<InvocationParameters>();

    return ThreadManager.callBackgroundStream(function: function, parameters: functionParameters);
  }

  @override
  Future<IChannel<S, R>> callBackgroundChannel<R, S>({required InvocationParameters parameters, required FutureOr<void> Function(InvocationContext context, IChannel<R, S> channel) function}) {
    final newParameters = InvocationParameters.list([function, parameters]);
    return _serverConnection.createChannel(parameters: newParameters, function: _callBackgroundChannelOnServer<R, S>);
  }

  static Future<void> _callBackgroundChannelOnServer<R, S>(InvocationContext context, IChannel<R, S> channel) async {
    final function = context.firts<FutureOr<void> Function(InvocationContext context, IChannel<R, S> channel)>();
    final functionParameters = context.second<InvocationParameters>();

    final newChannel = await ThreadManager.callBackgroundChannel(function: function, parameters: functionParameters);
    channel.joinWithOtherChannel(channel: newChannel, closeOtherChannelIfFinished: true, closeThisChannelIfFinish: true);
  }

  @override
  Future<R> callEntityFunction<T extends Object, R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(T p1, InvocationContext p2) function}) async {
    if (T == entityType) {
      return function(_entity, InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters));
    }

    final actualConnection = _connectionstList.selectItem((x) => x.entityType == T);
    if (actualConnection != null) {
      return await actualConnection.callEntityFunction<T, R>(function: function, parameters: parameters);
    }

    final newConnection = await getEntityInstance<T>();
    if (newConnection == null) {
      throw NegativeResult(identifier: NegativeResultCodes.contextInvalidFunctionality, message: Oration(message: 'There is no thread that manages the entity %1', textParts: [T]));
    }

    return newConnection.callEntityFunction<T, R>(function: function, parameters: parameters);
  }

  @override
  Future<Stream<R>> callEntityStream<T extends Object, R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<Stream<R>> Function(T, InvocationContext) function}) async {
    if (T == entityType) {
      return await function(_entity, InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters));
    }

    final actualConnection = _connectionstList.selectItem((x) => x.entityType == T);
    if (actualConnection != null) {
      return await actualConnection.callEntityStream<T, R>(function: function, parameters: parameters);
    }

    final newConnection = await getEntityInstance<T>();
    if (newConnection == null) {
      throw NegativeResult(identifier: NegativeResultCodes.contextInvalidFunctionality, message: Oration(message: 'There is no thread that manages the entity %1', textParts: [T]));
    }

    return newConnection.callEntityStream<T, R>(function: function, parameters: parameters);
  }

  @override
  Future<R> callFunction<R>({required InvocationParameters parameters, required FutureOr<R> Function(InvocationContext p1) function}) async {
    return function(InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters));
  }

  @override
  Future<R> callFunctionOnTheServer<R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(InvocationContext p1) function}) {
    return _serverConnection.callFunction(parameters: parameters, function: function);
  }

  @override
  Future<Stream<R>> callStreamOnTheServer<R>({required InvocationParameters parameters, required FutureOr<Stream<R>> Function(InvocationContext p1) function}) {
    return _serverConnection.callStream(parameters: parameters, function: function);
  }

  @override
  Future<Stream<R>> callStream<R>({required InvocationParameters parameters, required FutureOr<Stream<R>> Function(InvocationContext p1) function, bool cancelOnError = false}) async {
    return await function(InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters));
  }

  @override
  Future<IThreadInvokeInstance?> getEntityInstance<T extends Object>() async {
    final actualConnection = _connectionstList.selectItem((x) => x.entityType == T);
    if (actualConnection != null) {
      return actualConnection;
    }

    final sendPort = await _serverConnection.callFunction(parameters: InvocationParameters.emptry, function: _getEntityInstance<T>);

    if (sendPort == null) {
      return null;
    }

    return await hookPoint(sendPort);
  }

  static Future<SendPort?> _getEntityInstance<T extends Object>(InvocationContext context) async {
    final server = volatile(detail: Oration(message: 'Thread is not ThreadIsolatorServer'), function: () => context.thread as ThreadIsolatorServer);

    final connection = await server.getEntityInstance<T>();
    if (connection == null) {
      return null;
    }

    return await connection.getConnectionSendPort();
  }

  @override
  Future<IThreadInvokeInstance?> getEntityInstanceByName({required String name}) async {
    final actualConnection = _connectionstList.selectItem((x) => x.entityType != null && x.entityType.toString() == name);
    if (actualConnection != null) {
      return actualConnection;
    }

    final sendPort = await _serverConnection.callFunction(parameters: InvocationParameters.only(name), function: _getEntityInstanceByName);

    if (sendPort == null) {
      return null;
    }

    return await hookPoint(sendPort);
  }

  static Future<SendPort?> _getEntityInstanceByName(InvocationContext context) async {
    final server = volatile(detail: Oration(message: 'Thread is not ThreadIsolatorServer'), function: () => context.thread as ThreadIsolatorServer);
    final name = context.firts<String>();

    final connection = await server.getEntityInstanceByName(name: name);
    if (connection == null) {
      return null;
    }

    return await connection.getConnectionSendPort();
  }

  @override
  Future<IThreadInvokeInstance?> getIDInstance({required int id}) async {
    final actualConnection = _connectionstList.selectItem((x) => x.threadID == id);
    if (actualConnection != null) {
      return actualConnection;
    }

    final sendPort = await _serverConnection.callFunction(parameters: InvocationParameters.list([id]), function: _getIDInstance);

    if (sendPort == null) {
      return null;
    }

    return await hookPoint(sendPort);
  }

  static Future<SendPort?> _getIDInstance(InvocationContext context) async {
    final id = context.firts<int>();

    final server = volatile(detail: Oration(message: 'Thread is not ThreadIsolatorServer'), function: () => context.thread as ThreadIsolatorServer);

    final connection = await server.getIDInstance(id: id);
    if (connection == null) {
      return null;
    }

    return await connection.getConnectionSendPort();
  }

  @override
  Future<IThreadInvokeInstance> mountEntity<T extends Object>({required T entity, bool ifExistsOmit = true}) async {
    final actualConnection = _connectionstList.selectItem((x) => x.entityType == entity.runtimeType);
    if (actualConnection != null) {
      return actualConnection;
    }

    final sendPort = await _serverConnection.callFunction(parameters: InvocationParameters.list([entity, ifExistsOmit]), function: _mountEntity<T>);
    return await hookPoint(sendPort);
  }

  static Future<SendPort> _mountEntity<T extends Object>(InvocationContext context) async {
    final entity = context.firts<T>();
    final ifExistsOmit = context.second<bool>();

    final server = volatile(detail: Oration(message: 'Thread is not ThreadIsolatorServer'), function: () => context.thread as ThreadIsolatorServer);

    final connection = await server.mountEntity<T>(entity: entity, ifExistsOmit: ifExistsOmit);

    return await connection.getConnectionSendPort();
  }

  @override
  void closeThread() {
    Future.delayed(Duration.zero).whenComplete(() async {
      for (final item in _connectionstList) {
        item.closeConnection();
      }
      _serverConnection.closeConnection();
      await streamManager.close();

      channelsManager.closeAll();

      Future.delayed(Duration(milliseconds: 20)).whenComplete(() {
        containErrorLog(
          detail: Oration(message: '[IsolateInitializer] FAILED!: The negative result cannot be sent to the other isolator.'),
          function: () => Isolate.exit(),
        );
      });
    });
  }

  Future<SendPort> getConnectionSendPort() async {
    final newTip = ChannelIsolates.createInitialChannelManually();

    final uninitializedConnection = ThreadIsolatorClientConnection(clientMannager: this, channel: newTip, threadID: -1);

    _connectionstList.add(uninitializedConnection);
    uninitializedConnection.done.then((x) => _connectionstList.remove(x));

    newTip.wasInitialized.then((_) => _initializeChannel(uninitializedConnection));

    return newTip.serder;
  }

  Future<ThreadIsolatorClientConnection> hookPoint(SendPort port) async {
    final channel = ChannelIsolates.createDestinationChannel(sender: port, sendSender: true);
    final newClient = ThreadIsolatorClientConnection(clientMannager: this, channel: channel, threadID: -1);

    _connectionstList.add(newClient);
    newClient.done.then((x) => _connectionstList.remove(x));

    await _initializeChannel(newClient);

    return newClient;
  }

  Future<void> _initializeChannel(ThreadIsolatorClientConnection client) async {
    final threadID = await client.callFunction(
      parameters: InvocationParameters.emptry,
      function: (x) async => x.thread.threadID,
    );

    final entityType = await client.callFunction(
      parameters: InvocationParameters.emptry,
      function: (x) async => x.thread.entityType,
    );

    client.initialize(threadID: threadID, entityType: entityType);
  }

  @override
  Future<IChannel<S, R>> createChannel<R, S>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<void> Function(InvocationContext context, IChannel<R, S> channel) function}) async {
    final master = MasterChannel<R, S>(closeIfEveryoneClosed: true);

    maxiScheduleMicrotask(() async {
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
    if (T == entityType) {
      final master = MasterChannel<R, S>(closeIfEveryoneClosed: true);

      maxiScheduleMicrotask(() async {
        try {
          await function(_entity, InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters), master);
        } catch (ex, st) {
          master.addErrorIfActive(ex, st);
          master.close();
        }
      });

      return master.createSlave();
    }

    final actualConnection = _connectionstList.selectItem((x) => x.entityType == T);
    if (actualConnection != null) {
      return await actualConnection.createEntityChannel<T, R, S>(function: function, parameters: parameters);
    }

    final newConnection = await getEntityInstance<T>();
    if (newConnection == null) {
      throw NegativeResult(identifier: NegativeResultCodes.contextInvalidFunctionality, message: Oration(message: 'There is no thread that manages the entity %1', textParts: [T]));
    }

    return await newConnection.createEntityChannel<T, R, S>(function: function, parameters: parameters);
  }
}
