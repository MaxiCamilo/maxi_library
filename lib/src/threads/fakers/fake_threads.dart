import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/fakers/fake_thread_invoke_instance.dart';
import 'package:maxi_library/src/threads/fakers/fake_thread_pipe_processor.dart';
import 'package:maxi_library/src/threads/iexternal_thread_stream_processor.dart';
import 'package:maxi_library/src/threads/ithread_invoke_instance.dart';

class FakeThreads with IThreadInvoker, IThreadManager {
  @override
  final ThreadPipeProcessor pipeProcessor = FakeThreadPipeProcessor();

  @override
  int get threadID => 0;

  @override
  Map<Type, FakeThreadInvokeInstance> connectionWithServices = <Type, FakeThreadInvokeInstance>{};

  @override
  List<FakeThreadInvokeInstance> connections = [];

  int _lastId = 1;

  FakeThreadInvokeInstance selectEntityConnection<T>() {
    final item = connectionWithServices[T];
    if (item == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: tr('Entity %1 was not previously mounted', [T]),
      );
    } else {
      return item;
    }
  }

  @override
  Future<R> callBackgroundFunction<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationContext para) function}) {
    return function(InvocationContext.fromParametes(thread: this, parametres: parameters));
  }

  @override
  Future<R> callEntityFunction<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(T p1, InvocationContext p2) function}) {
    return selectEntityConnection<T>().callEntityFunction(function: function, parameters: parameters);
  }

  @override
  Future<Stream<R>> callEntityStream<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(T p1, InvocationContext p2) function, bool cancelOnError = false}) {
    return selectEntityConnection<T>().callEntityStream(function: function, parameters: parameters);
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
  Future<IThreadInvokeInstance> mountEntity<T extends Object>({required T entity, bool ifExistsOmit = true}) async {
    final exists = connectionWithServices[T];
    if (exists != null) {
      if (ifExistsOmit) {
        return exists;
      } else {
        throw NegativeResult(identifier: NegativeResultCodes.invalidFunctionality, message: tr('Entity %1 has already been mounted'));
      }
    }

    final newFaker = FakeThreadInvokeInstance(server: this, id: _lastId, entity: entity);
    _lastId += 1;

    if (entity is StartableFunctionality) {
      await entity.initialize();
    }

    connections.add(newFaker);
    connectionWithServices[T] = newFaker;

    return newFaker;
  }

  @override
  void closeThread() {
    log('[FakeThreads] Can not close a fake thread');
  }

  @override
  Future<ThreadPipe<R, S>> connectWithEntityBroadcastPipe<T, R, S>({InvocationParameters parameters = InvocationParameters.emptry, required Future<BroadcastPipe<R, S>> Function(T p1, InvocationContext p2) function}) {
    throw UnimplementedError();
  }

  @override
  get entity => null;

  @override
  Future<IThreadInvokeInstance> locateConnection(int id) async {
    final item = connections.selectItem((x) => x.id == id);
    if (item == null) {
      throw NegativeResult(identifier: NegativeResultCodes.nonExistent, message: tr('Thread %1 not found', [id]));
    }

    return item;
  }
}
