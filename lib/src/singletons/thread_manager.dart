import 'package:maxi_library/maxi_library.dart';

mixin ThreadManager {
  static IThreadManager? _instance;
  static IThreadManagersFactory generalFactory = const IsolatedThreadFactory();
  //static List<IThreadInitializer> initializerForNewIsolates = [];

  static IThreadManager get instance {
    if (_instance != null) {
      return _instance!;
    }

    _instance = generalFactory.createServer(threadInitializer: []);

    return _instance!;
  }

  static set instance(IThreadManager newInvoker) {
    if (_instance != null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: tr('[ThreadManager] Thread manager has already been initialized'),
      );
    }

    _instance = newInvoker;
  }

  static Future<R> callFunctionAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationParameters parameters) function}) =>
      instance.callFunctionAsAnonymous<R>(function: function, parameters: parameters);
  static Future<Stream<R>> callStreamAsAnonymous<R>(
          {InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(InvocationParameters parameters) function, bool cancelOnError = false}) =>
      instance.callStreamAsAnonymous<R>(function: function, parameters: parameters, cancelOnError: cancelOnError);

  static Future<R> callEntityFunction<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(T service, InvocationParameters parameters) function}) =>
      instance.callEntityFunction<T, R>(function: function, parameters: parameters);
  static Future<Stream<R>> callEntityStream<T, R>(
          {InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(T service, InvocationParameters parameters) function, bool cancelOnError = false}) =>
      instance.callEntityStream<T, R>(function: function, parameters: parameters, cancelOnError: cancelOnError);

  static Future<void> mountEntity<T extends Object>({required T entity, bool ifExistsOmit = true}) => instance.mountEntity<T>(entity: entity, ifExistsOmit: ifExistsOmit);

  static void addThreadInitializer({required IThreadInitializer initializer}) {
    if (instance is IThreadManagerServer) {
      (instance as IThreadManagerServer).addThreadInitializer(initializer: initializer);
    }
  }
}
