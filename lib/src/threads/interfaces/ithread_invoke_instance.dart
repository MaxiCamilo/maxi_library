import 'package:maxi_library/maxi_library.dart';

mixin IThreadInvokeInstance on IThreadInvoker {
  //Future<R> callEntityFunction<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(T p1, InvocationContext p2) function});
//Future<Stream<R>> callEntityStream<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(T p1, InvocationContext p2) function, bool cancelOnError = false});

  Future<IThreadInvokeInstance> get done;

  void requestEndOfThread();
  void closeConnection();
  void declareClosed();
}
