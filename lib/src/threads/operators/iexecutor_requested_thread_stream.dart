import 'package:maxi_library/src/threads/invocation_parameters.dart';

mixin IExecutorRequestedThreadStream {
  Future<void> executeRequestedStream({
    required InvocationParameters parameters,
    required Future<Stream> Function(InvocationParameters) function,
  });

  Future<void> executeRequestedEntityStream<T>({
    required InvocationParameters parameters,
    required Future<Stream> Function(T, InvocationParameters) function,
  });

  void cancelStream(int idStream);

  void reactClosingThread();
}
