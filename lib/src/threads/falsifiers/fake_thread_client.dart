import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/falsifiers/fake_thread_server.dart';

class FakeThreadClient with IThreadInvoker, IThreadManager, IThreadManagerClient, IThreadInvokeInstance, IFakeThread {
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

  final _onDone = MaxiCompleter<IThreadInvokeInstance>();

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
  Future<Stream<R>> callStreamOnTheServer<R>({required InvocationParameters parameters, required FutureOr<Stream<R>> Function(InvocationContext p1) function}) async {
    return await function(InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters));
  }

  @override
  Future<Stream<R>> callBackgroundStream<R>({required InvocationParameters parameters, required FutureOr<Stream<R>> Function(InvocationContext p1) function}) async {
    return await function(InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters));
  }

  @override
  Future<IChannel<S, R>> callBackgroundChannel<R, S>({required InvocationParameters parameters, required FutureOr<void> Function(InvocationContext context, IChannel<R, S> channel) function}) async {
    final master = MasterChannel<S, R>(closeIfEveryoneClosed: true);

    maxiScheduleMicrotask(() async {
      final slaver = master.createSlave();
      await function(InvocationContext.fromParametes(thread: this, applicant: this, parametres: parameters), slaver);
    });

    return master;
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
    if (T != entityType) {
      return serverConnection.createEntityChannel<T, R, S>(function: function, parameters: parameters);
    }

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

  @override
  Future<IThreadInvokeInstance?> getEntityInstanceByName({required String name}) {
    return serverConnection.getEntityInstanceByName(name: name);
  }
}
