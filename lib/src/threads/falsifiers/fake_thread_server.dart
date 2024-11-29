import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/falsifiers/fake_thread_client.dart';

class FakeThreadServer with IThreadInvoker, IThreadManager, IThreadManagerServer, IThreadInvokeInstance {
  final _clients = <FakeThreadClient>[];

  int _lastID = 1;

  @override
  void addThreadInitializer({required IThreadInitializer initializer}) {}

  @override
  int get threadID => 0;

  @override
  bool get isServer => true;

  @override
  Type? get entityType => null;

  @override
  Future<IThreadInvokeInstance> get done => throw UnimplementedError('Never end');

  @override
  Future<R> callBackgroundFunction<R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(InvocationContext para) function}) async {
    return await function(InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters));
  }

  @override
  Future<R> callFunction<R>({required InvocationParameters parameters, required FutureOr<R> Function(InvocationContext p1) function}) async {
    return await function(InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters));
  }

  @override
  Future<R> callFunctionOnTheServer<R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(InvocationContext p1) function}) async {
    return await function(InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters));
  }

  @override
  Future<Stream<R>> callStream<R>({required InvocationParameters parameters, required FutureOr<Stream<R>> Function(InvocationContext p1) function}) async {
    return await function(InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters));
  }

  @override
  void closeThread() {
    log('[FakeThreadServer] ¡This thread server cannot be closed!');
  }

  @override
  Future<IPipe<S, R>> createPipe<R, S>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<void> Function(InvocationContext context, IPipe<R, S> pipe) function}) async {
    final internalPipe = BroadcastPipe<R, S>(closeIfNoOneListens: false, closeConnectedPipesIfFinished: true);

    scheduleMicrotask(() => function(InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters), internalPipe));

    final externalPipe = BroadcastPipe<S, R>(closeIfNoOneListens: false, closeConnectedPipesIfFinished: false);
    externalPipe.joinCrossPipe(pipe: internalPipe, closeThisPipeIfFinish: true);

    return externalPipe;
  }

  void closeClient(FakeThreadClient client) {
    _clients.remove(client);
    client.declareClosed();
  }

  @override
  Future<IPipe<S, R>> createEntityPipe<T extends Object, R, S>(
      {InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<void> Function(T entity, InvocationContext context, IPipe<R, S> pipe) function}) {
    return getClientByEntity<T>().createEntityPipe<T, R, S>(function: function, parameters: parameters);
  }

  @override
  Future<R> callEntityFunction<T extends Object, R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(T p1, InvocationContext p2) function}) {
    return getClientByEntity<T>().callEntityFunction<T, R>(function: function, parameters: parameters);
  }

  @override
  Future<Stream<R>> callEntityStream<T extends Object, R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<Stream<R>> Function(T p1, InvocationContext p2) function}) {
    return getClientByEntity<T>().callEntityStream<T, R>(function: function, parameters: parameters);
  }

  @override
  Future<T?> getEntity<T extends Object>() async {
    return _clients.selectItem((x) => x.entityType == T)?.getEntity();
  }

  @override
  Future<IThreadInvokeInstance?> getEntityInstance<T extends Object>() async {
    return _clients.selectItem((x) => x.entityType == T);
  }

  @override
  Future<IThreadInvokeInstance?> getIDInstance({required int id}) async {
    return _clients.selectItem((x) => x.threadID == id);
  }

  @override
  Future<IThreadInvokeInstance> mountEntity<T extends Object>({required T entity, bool ifExistsOmit = true}) async {
    final exists = await getEntityInstance<T>();
    if (exists != null) {
      if (ifExistsOmit) {
        return exists;
      } else {
        throw NegativeResult(identifier: NegativeResultCodes.contextInvalidFunctionality, message: tr('Entity thread %1 has already been mounted', [T]));
      }
    }

    final thread = await makeNewThread(initializers: [], name: '');
    try {
      await thread.setEntity(entity);
    } catch (_) {
      _clients.remove(thread);
    }

    return thread;
  }

  @override
  Future<FakeThreadClient> makeNewThread({required List<IThreadInitializer> initializers, required String name}) async {
    final id = _lastID;
    _lastID += 1;

    final newClient = FakeThreadClient(serverConnection: this, threadID: id, entity: null);
    _clients.add(newClient);
    return newClient;
  }

  @override
  Future<void> setEntity(newEnity) async {
    final exists = _clients.selectItem((x) => x.entityType == newEnity.runtimeType);
    if (exists == null) {
      final thread = await makeNewThread(initializers: [], name: '');
      try {
        await thread.setEntity(newEnity);
      } catch (_) {
        _clients.remove(thread);
      }
    } else {
      exists.setEntity(newEnity);
    }
  }

  @override
  void closeConnection() {}

  @override
  void declareClosed() {}

  @override
  void requestEndOfThread() {}

  FakeThreadClient getClientByEntity<T extends Object>() {
    final result = _clients.selectItem((x) => x.entityType == T);
    if (result == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: tr('Instance thread %1 has not been mounted', [T]),
      );
    }

    return result;
  }
}
