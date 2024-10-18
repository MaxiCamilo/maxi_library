import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/iexternal_thread_stream_processor.dart';
import 'package:maxi_library/src/threads/isolates/isolate_thread_pipe_processor.dart';
import 'package:maxi_library/src/threads/isolates/isolate_initializer.dart';
import 'package:maxi_library/src/threads/isolates/isolate_thread_connection.dart';
import 'package:maxi_library/src/threads/isolates/isolated_thread_client.dart';
import 'package:maxi_library/src/threads/ithread_invoke_instance.dart';
import 'package:maxi_library/src/threads/processors/background_processor.dart';
import 'package:maxi_library/src/threads/processors/thread_invoke_instance.dart';

class IsolatedThreadServer with IThreadInvoker, IThreadManager, IThreadManagerServer {
  @override
  int get threadID => 0;

  final Set<IThreadInitializer> _initializers = {};

  final _entityMountSynchronizer = Semaphore();

  late final BackgroundProcessor _backgroudProcessor;

  @override
  final connectionWithServices = <Type, IThreadInvokeInstance>{};

  @override
  final connections = <IThreadInvokeInstance>[];

  @override
  final ThreadPipeProcessor pipeProcessor = IsolateThreadPipeProcessor();

  @override
  get entity => null;

  int _lastThreadID = 1;

  IsolatedThreadServer() {
    _backgroudProcessor = BackgroundProcessor(server: this);
  }

  @override
  void addThreadInitializer({required IThreadInitializer initializer}) {
    _initializers.add(initializer);
  }

  @override
  Future<R> callEntityFunction<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(T p1, InvocationContext p2) function}) {
    final connection = _getConnectionByEntity<T>();

    return connection.callEntityFunction<T, R>(function: function, parameters: parameters);
  }

  @override
  Future<Stream<R>> callEntityStream<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(T p1, InvocationContext p2) function, bool cancelOnError = false}) {
    final connection = _getConnectionByEntity<T>();
    return connection.callEntityStream<T, R>(function: function, parameters: parameters, cancelOnError: cancelOnError);
  }

  @override
  Future<R> callFunctionAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationContext p1) function}) {
    return function(InvocationContext.fromParametes(thread: this, parametres: parameters));
  }

  @override
  Future<R> callFunctionOnTheServer<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationContext p1) function}) {
    return function(InvocationContext.fromParametes(thread: this, parametres: parameters));
  }

  @override
  Future<Stream<R>> callStreamAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(InvocationContext p1) function, bool cancelOnError = false}) {
    return function(InvocationContext.fromParametes(thread: this, parametres: parameters));
  }

  @override
  void closeThread() {
    log('[Isolated Thread Server] ¡This is the thread server, it cannot be closed!');
  }

  @override
  Future<SendPort> getRawConnectionAccordingToEntity<T>() {
    final connection = _getConnectionByEntity<T>();
    return connection.callFunctionAsAnonymous(function: _getSendPortFromClient);
  }

  static Future<SendPort> _getSendPortFromClient(InvocationContext parameters) {
    final client = parameters.thread as IsolatedThreadClient;
    return client.getConnectionTip();
  }

  @override
  Future<IThreadInvokeInstance> mountEntity<T extends Object>({required T entity, bool ifExistsOmit = true}) async {
    checkProgrammingFailure(thatChecks: tr('Type Entity %1 is not dynamic', [T]), result: () => T != dynamic);

    final exists = connectionWithServices[T];

    if (exists != null) {
      if (ifExistsOmit) {
        return exists;
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.contextInvalidFunctionality,
          message: tr('Entity %1 has already been mounted', [T]),
        );
      }
    }

    return await _entityMountSynchronizer.execute(function: () async {
      final existsAgain = connectionWithServices[T];

      if (existsAgain != null) {
        return existsAgain;
      }

      final name = entity is ThreadService ? entity.serviceName : T.toString();
      final newThread = await makeNewThread(initializers: [], name: name);

      newThread.done.then(_reactConnectionClose);

      try {
        await newThread.callFunctionAsAnonymous(parameters: InvocationParameters.only(entity), function: _mountEntityOnClient);
      } catch (_) {
        newThread.requestEndOfThread();
        rethrow;
      }

      newThread.entityType = T;
      connectionWithServices[T] = newThread;

      return newThread;
    });
  }

  FutureOr<void> _reactConnectionClose(IThreadInvokeInstance connection) {
    connections.remove(connection);
    connectionWithServices.removeWhere((_, x) => x == connection);
  }

  static Future<void> _mountEntityOnClient<T extends Object>(InvocationContext parameters) async {
    final entity = parameters.firts<T>();
    final client = (parameters.thread as IThreadManagerClient);

    await client.defineAsService(newEntity: entity);
  }

  @override
  Future<IThreadInvokeInstance> makeNewThread({required List<IThreadInitializer> initializers, required String name}) async {
    final allInitializers = [..._initializers, ...initializers];
    final threadInitializer = IsolateInitializer(initializers: allInitializers);

    final threadID = _lastThreadID;
    _lastThreadID += 1;

    final channel = await threadInitializer.mountIsolate(name: name, threadID: threadID);
    final connection = IsolateThreadConnection(channel: channel);
    final newThread = ThreadInvokeInstance(connection: connection, isConnectionServer: false, manager: this, entityType: null);
    newThread.defineThreadID(threadID);

    connections.add(newThread);

    return newThread;
  }

  IThreadInvokeInstance _getConnectionByEntity<T>() {
    checkProgrammingFailure(thatChecks: tr('Type Entity %1 is not dynamic', [T]), result: () => T != dynamic);

    final exists = connectionWithServices[T];
    if (exists == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: tr('there is no service mounted for entity %1', [T]),
      );
    }

    return exists;
  }

  @override
  Future<IThreadInvokeInstance> locateConnection(int id) async {
    checkProgrammingFailure(thatChecks: tr('ID must not be 0'), result: () => id > 0);
    final connection = await connections.selectItemAsync((x) async => (await x.getThreadID()) == id);
    if (connection == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: tr('There is no thread with ID number %1', [id]),
      );
    }

    return connection;
  }

  @override
  Future getRawConnectionAccordingToID(int id) async {
    return (await locateConnection(id)).callFunctionAsAnonymous(function: _getSendPortFromClient);
  }

  @override
  Future<R> callBackgroundFunction<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationContext para) function}) {
    return _backgroudProcessor.callBackgroundFunction<R>(function: function, parameters: parameters);
  }

  @override
  Future<ThreadPipe<R, S>> connectWithEntityBroadcastPipe<T, R, S>({InvocationParameters parameters = InvocationParameters.emptry, required Future<BroadcastPipe<R, S>> Function(T p1, InvocationContext p2) function}) {
    final connection = _getConnectionByEntity<T>();
    return connection.connectWithEntityBroadcastPipe<T, R, S>(function: function, parameters: parameters);
  }
}
