import 'package:maxi_library/src/threads.dart';

mixin IThreadStreamManager {
  Future<Stream<R>> callStreamAsAnonymous<R>({
    InvocationParameters parameters = InvocationParameters.emptry,
    required Future<Stream<R>> Function(InvocationParameters) function,
    bool isBroadcast = false,
  });

  Future<Stream<R>> callEntityStream<T, R>({
    InvocationParameters parameters = InvocationParameters.emptry,
    required Future<Stream<R>> Function(T, InvocationParameters) function,
    bool isBroadcast = false,
  });

  void confirmStreamRunning(int idStream);

  void confirmStreamFailure(int idStream, dynamic error);

  void confirmStreamEnd(int idStream);

  void confirmStreamItem(int idStream, dynamic item);

  void confirmStreamError(int idStream, dynamic failure);

  void cancelStream(int idStream);

  void reactClosingThread();
}
