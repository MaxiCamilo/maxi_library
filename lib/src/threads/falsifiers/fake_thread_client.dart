import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/falsifiers/fake_thread_server.dart';

class FakeThreadClient with IThreadInvoker, IThreadManager, IThreadManagerClient, IThreadInvokeInstance {
  @override
  final int threadID;

  @override
  final FakeThreadServer serverConnection;

  @override
  bool get isServer => false;

  @override
  Type? get entityType => _entity?.runtimeType;

  @override
  Future<IThreadInvokeInstance> get done => _onDone.future;

  dynamic _entity;

  final _onDone = Completer<IThreadInvokeInstance>();

  FakeThreadClient({required this.threadID, required this.serverConnection, dynamic entity}) {
    _entity = entity;
  }

  @override
  Future<T?> getEntity<T extends Object>() async {
    if (_entity is T) {
      return _entity;
    } else {
      return null;
    }
  }

  @override
  Future<void> setEntity(newEnity) async {
    if (newEnity is StartableFunctionality) {
      await newEnity.initialize();
    }

    _entity = newEnity;
  }

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
  Future<Stream<R>> callBackgroundStream<R>({required InvocationParameters parameters, required FutureOr<Stream<R>> Function(InvocationContext p1) function}) async {
    return await function(InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters));
  }

  @override
  Future<Stream<R>> callStream<R>({required InvocationParameters parameters, required FutureOr<Stream<R>> Function(InvocationContext p1) function}) async {
    return await function(InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters));
  }

  @override
  void closeThread() {
    serverConnection.closeClient(this);
  }

  @override
  Future<IPipe<S, R>> createPipe<R, S>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<void> Function(InvocationContext context, IPipe<R, S> pipe) function}) async {
    //CREO QUE ESTÁ MAL
    final internalPipe = BroadcastPipe<R, S>(closeIfNoOneListens: false, closeConnectedPipesIfFinished: true);

    scheduleMicrotask(() => function(InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters), internalPipe));

    final externalPipe = BroadcastPipe<S, R>(closeIfNoOneListens: false, closeConnectedPipesIfFinished: false);
    externalPipe.joinCrossPipe(pipe: internalPipe, closeThisPipeIfFinish: true);

    return externalPipe;
  }

  @override
  Future<R> callEntityFunction<T extends Object, R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(T p1, InvocationContext p2) function}) async {
    if (T == entityType) {
      return await function(_entity, InvocationContext.fromParametes(thread: serverConnection, applicant: this, parametres: parameters));
    } else {
      return serverConnection.callEntityFunction<T, R>(function: function, parameters: parameters);
    }
  }

  @override
  Future<Stream<R>> callEntityStream<T extends Object, R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<Stream<R>> Function(T p1, InvocationContext p2) function}) async {
    if (T == entityType) {
      return await function(_entity, InvocationContext.fromParametes(thread: serverConnection, applicant: this, parametres: parameters));
    } else {
      return serverConnection.callEntityStream<T, R>(function: function, parameters: parameters);
    }
  }

  @override
  Future<IPipe<S, R>> createEntityPipe<T extends Object, R, S>(
      {InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<void> Function(T entity, InvocationContext context, IPipe<R, S> pipe) function}) async {
    if (T != entityType) {
      return await serverConnection.createEntityPipe<T, R, S>(function: function, parameters: parameters);
    }

    final internalPipe = BroadcastPipe<R, S>(closeIfNoOneListens: false, closeConnectedPipesIfFinished: true);

    scheduleMicrotask(() => function(_entity, InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters), internalPipe));

    final externalPipe = BroadcastPipe<S, R>(closeIfNoOneListens: false, closeConnectedPipesIfFinished: false);
    externalPipe.joinCrossPipe(pipe: internalPipe, closeThisPipeIfFinish: true);

    return externalPipe;
  }

  @override
  Future<IThreadInvokeInstance?> getEntityInstance<T extends Object>() async {
    if (T == entityType) {
      return this;
    }

    return serverConnection.getEntityInstance<T>();
  }

  @override
  Future<IThreadInvokeInstance?> getIDInstance({required int id}) async {
    if (threadID == id) {
      return this;
    }

    return serverConnection.getIDInstance(id: id);
  }

  @override
  Future<IThreadInvokeInstance> mountEntity<T extends Object>({required T entity, bool ifExistsOmit = true}) {
    return serverConnection.mountEntity<T>(entity: entity, ifExistsOmit: ifExistsOmit);
  }

  @override
  void closeConnection() {
    serverConnection.closeClient(this);
  }

  @override
  void declareClosed() {
    _onDone.completeIfIncomplete(this);
  }

  @override
  void requestEndOfThread() {
    closeConnection();
  }
}
