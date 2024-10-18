import 'package:maxi_library/maxi_library.dart';

mixin IThreadInvokeInstance {
  Type? get entityType;
  set entityType(Type? type);

  Future<R> callEntityFunction<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(T p1, InvocationContext p2) function});
  Future<Stream<R>> callEntityStream<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(T p1, InvocationContext p2) function, bool cancelOnError = false});

  Future<R> callFunctionAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationContext p1) function});
  Future<Stream<R>> callStreamAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(InvocationContext p1) function, bool cancelOnError = false});

  Future<ThreadPipe<R, S>> connectWithBroadcastPipe<R, S>({InvocationParameters parameters = InvocationParameters.emptry, required Future<BroadcastPipe<R, S>> Function(InvocationContext p1) function});
  Future<ThreadPipe<R, S>> connectWithEntityBroadcastPipe<T, R, S>({InvocationParameters parameters = InvocationParameters.emptry, required Future<BroadcastPipe<R, S>> Function(T p1, InvocationContext p2) function});

  Future<IThreadInvokeInstance> get done;

  void closeConnection();
  void requestEndOfThread();

  Future<int> getThreadID();
  void defineThreadID(int id);
}
