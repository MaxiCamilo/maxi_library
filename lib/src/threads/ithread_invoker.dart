import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/ithread_invoke_instance.dart';

mixin IThreadInvoker {
  Future<R> callFunctionAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationContext) function});
  Future<Stream<R>> callStreamAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(InvocationContext) function, bool cancelOnError = false});

  Future<R> callEntityFunction<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(T, InvocationContext) function});
  Future<Stream<R>> callEntityStream<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(T, InvocationContext) function, bool cancelOnError = false});

  Future<IThreadInvokeInstance> mountEntity<T extends Object>({required T entity, bool ifExistsOmit = true});

  Future<R> callFunctionOnTheServer<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationContext) function});
  Future<R> callBackgroundFunction<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationContext para) function});

  Future<ThreadPipe<R, S>> connectWithEntityBroadcastPipe<T, R, S>({InvocationParameters parameters = InvocationParameters.emptry, required Future<BroadcastPipe<R, S>> Function(T p1, InvocationContext p2) function});
}
