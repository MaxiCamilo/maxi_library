import 'package:maxi_library/src/threads.dart';

mixin IExecutorRequestedThreadFunctions {
  Future<void> executeRequestedFunction({
    required InvocationParameters parameters,
    required dynamic Function(InvocationParameters) function,
  });

  Future<void> executeRequestedEntityFunction<T>({
    required InvocationParameters parameters,
    required dynamic Function(T, InvocationParameters) function,
  });
}
