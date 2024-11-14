import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/fakers/fake_threads.dart';
import 'package:maxi_library/src/threads/iexternal_thread_stream_processor.dart';
import 'package:maxi_library/src/threads/ithread_invoke_instance.dart';

class FakeThreadInvokeInstance with IThreadInvoker, IThreadManager, IThreadInvokeInstance {
  final FakeThreads server;

  @override
  List<IThreadInvokeInstance> get connections => server.connections;

  @override
  Type? entityType;
  @override
  dynamic entity;

  int id;

  FakeThreadInvokeInstance({
    required this.server,
    required this.id,
    this.entity,
  }) {
    if (entity != null) {
      entityType = entity.runtimeType;
    }
  }

  T _checkEntity<T>() {
    if (entity == null || entity is! T) {
      throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: tr('Incorrect entity type'));
    }

    return entity as T;
  }

  @override
  Future<R> callEntityFunction<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(T p1, InvocationContext p2) function}) {
    return function(_checkEntity(), InvocationContext.fromParametes(thread: this, parametres: parameters));
  }

  @override
  Future<Stream<R>> callEntityStream<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(T p1, InvocationContext p2) function, bool cancelOnError = false}) {
    return function(_checkEntity(), InvocationContext.fromParametes(thread: this, parametres: parameters));
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
  void closeConnection() {
    server.connections.remove(this);
  }

  @override
  Future<ThreadPipe<R, S>> connectWithBroadcastPipe<R, S>({InvocationParameters parameters = InvocationParameters.emptry, required Future<BroadcastPipe<R, S>> Function(InvocationContext p1) function}) {
    throw UnimplementedError();
  }

  @override
  Future<ThreadPipe<R, S>> connectWithEntityBroadcastPipe<T, R, S>({InvocationParameters parameters = InvocationParameters.emptry, required Future<BroadcastPipe<R, S>> Function(T p1, InvocationContext p2) function}) {
    throw UnimplementedError();
  }

  @override
  void defineThreadID(int id) {
    this.id = id;
  }

  @override
  Future<IThreadInvokeInstance> get done => throw UnimplementedError();

  @override
  Future<int> getThreadID() async {
    return id;
  }

  @override
  void requestEndOfThread() {}

  @override
  Future<R> callBackgroundFunction<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationContext para) function}) {
    return function(InvocationContext.fromParametes(thread: this, parametres: parameters));
  }

  @override
  Future<R> callFunctionOnTheServer<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationContext p1) function}) {
    return function(InvocationContext.fromParametes(thread: this, parametres: parameters));
  }

  @override
  void closeThread() {
    server.connections.remove(this);
  }

  @override
  Map<Type, IThreadInvokeInstance> get connectionWithServices => server.connectionWithServices;

  @override
  Future<IThreadInvokeInstance> locateConnection(int id) async {
    return server.locateConnection(id);
  }

  @override
  Future<IThreadInvokeInstance> mountEntity<T extends Object>({required T entity, bool ifExistsOmit = true}) {
    return server.mountEntity<T>(entity: entity, ifExistsOmit: ifExistsOmit);
  }

  @override
  ThreadPipeProcessor get pipeProcessor => server.pipeProcessor;

  @override
  int get threadID => id;
}
