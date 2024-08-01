import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_communication.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_client.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_entity.dart';

mixin TemplateThreadProcessClienteStandar on IThreadInvoker, IThreadProcess, IThreadProcessClient {
  final mapConnectionsEntity = <Type, IThreadCommunication>{};

  final _entityRequestSynchronizer = Semaphore();

  Future<IThreadCommunication> obtainConnectionEntityManagerFromServer<T>();

  bool _checkIfIAmValidEntityManager<T>() => IThreadProcessEntity.checkGetItemFromProcess<T>(this) != null;

  @override
  Future<R> callEntityFunction<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(T p1, InvocationParameters p2) function}) async {
    if (_checkIfIAmValidEntityManager<T>()) {
      final item = IThreadProcessEntity.getItemFromProcess(this);
      return await function(item, parameters);
    }

    var connection = mapConnectionsEntity[T];
    connection ??= await searchEntityManager<T>();

    return await connection.requestManager.callEntityFunction<T, R>(parameters: parameters, function: function);
  }

  @override
  Future<Stream<R>> callEntityStream<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(T p1, InvocationParameters p2) function}) async {
    if (_checkIfIAmValidEntityManager<T>()) {
      final item = IThreadProcessEntity.getItemFromProcess(this);
      return await function(item, parameters);
    }

    var connection = mapConnectionsEntity[T];
    connection ??= await searchEntityManager<T>();

    return await connection.streamManager.callEntityStream<T, R>(parameters: parameters, function: function);
  }

  @override
  Future<R> callFunctionAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationParameters p1) function}) {
    return serverCommunicator.requestManager.callFunctionAsAnonymous<R>(function: function, parameters: parameters);
  }

  @override
  Future<Stream<R>> callStreamAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(InvocationParameters p1) function}) {
    return serverCommunicator.streamManager.callStreamAsAnonymous<R>(function: function, parameters: parameters);
  }

  @override
  Future<void> mountEntity<T>({required T entity, bool ifExistsOmit = true}) {
    throw UnimplementedError('Ups! I am running out of time to do this from the client threads');
  }

  @override
  void reactConnectionClose(IThreadCommunication closedCommunicator) {
    for (final item in mapConnectionsEntity.entries) {
      if (item.value == closedCommunicator) {
        mapConnectionsEntity.remove(item.key);
        break;
      }
    }
  }

  @override
  Future<R> callFunctionOnTheServer<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationParameters) function}) async {
    return serverCommunicator.requestManager.callFunctionInThread<R>(function: function, parameters: parameters);
  }

  @override
  Future<IThreadCommunication> searchEntityManager<T>() async {
    checkProgrammingFailure(thatChecks: () => 'There cannot exist a dynamic entity type', result: () => T != dynamic);

    final existing = mapConnectionsEntity[T];
    if (existing != null) {
      return existing;
    }

    final newConnection = await _entityRequestSynchronizer.execute(function: obtainConnectionEntityManagerFromServer<T>);
    mapConnectionsEntity[T] = newConnection;

    return newConnection;
  }
}
