import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/factories/threadm_managers_factory_isolator.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_magares_factory.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process.dart';

mixin ThreadManager {
  static IThreadInvoker? _instance;
  static IThreadManagersFactory generalFactory = const ThreadManagersFactoryIsolator();

  static List<IThreadInitializer> threadInitializers = const [];

  static IThreadInvoker get instance {
    if (_instance != null) {
      return _instance!;
    }

    _instance = generalFactory.createServer(threadInitializer: threadInitializers);

    return _instance!;
  }

  static set instance(IThreadInvoker newInvoker) {
    if (_instance != null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: '[ThreadManager] Thread manager has already been initialized',
      );
    }

    _instance = newInvoker;
  }

  static Future<R> callFunctionAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationParameters) function}) =>
      instance.callFunctionAsAnonymous<R>(function: function, parameters: parameters);
  static Future<Stream<R>> callStreamAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(InvocationParameters) function}) =>
      instance.callStreamAsAnonymous<R>(function: function, parameters: parameters);

  static Future<R> callEntityFunction<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(T, InvocationParameters) function}) =>
      instance.callEntityFunction<T, R>(function: function, parameters: parameters);
  static Future<Stream<R>> callEntityStream<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(T, InvocationParameters) function}) =>
      instance.callEntityStream<T, R>(function: function, parameters: parameters);

  static Future<void> mountEntity<T>({required T entity, bool ifExistsOmit = true}) => instance.mountEntity<T>(entity: entity, ifExistsOmit: ifExistsOmit);

  static IThreadProcess getProcess() {
    final item = instance;
    if (item is IThreadProcess) {
      return item;
    }

    throw NegativeResult(
      identifier: NegativeResultCodes.implementationFailure,
      message: '[ThreadManager] The invoker is not a process manager',
    );
  }
}
