import 'package:maxi_library/maxi_library.dart';

mixin IThreadRequestManager {
  Future<R> callFunctionAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationParameters) function});

  Future<R> callEntityFunction<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(T, InvocationParameters) function});

  void confirmTaskRunning(int idTask);

  void confirmTaskCompletion(int idTask, dynamic result);

  void confirmTaskFailure(int idTask, dynamic failure);

  void reactClosingThread();
}
