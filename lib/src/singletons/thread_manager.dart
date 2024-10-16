import 'dart:async';

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

  static Future<R> callFunctionAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationParameters para) function}) =>
      instance.callFunctionAsAnonymous<R>(function: function, parameters: parameters);
  static Future<Stream<R>> callStreamAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(InvocationParameters para) function, bool cancelOnError = false}) =>
      instance.callStreamAsAnonymous<R>(function: function, parameters: parameters, cancelOnError: cancelOnError);

  static Future<R> callEntityFunction<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(T serv, InvocationParameters para) function}) =>
      instance.callEntityFunction<T, R>(function: function, parameters: parameters);
  static Future<Stream<R>> callEntityStream<T, R>(
          {InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(T serv, InvocationParameters para) function, bool cancelOnError = false}) =>
      instance.callEntityStream<T, R>(function: function, parameters: parameters, cancelOnError: cancelOnError);

  static Future<void> mountEntity<T extends Object>({required T entity, bool ifExistsOmit = true}) => instance.mountEntity<T>(entity: entity, ifExistsOmit: ifExistsOmit);

  static void addThreadInitializer({required IThreadInitializer initializer}) {
    if (instance is IThreadManagerServer) {
      (instance as IThreadManagerServer).addThreadInitializer(initializer: initializer);
    }
  }

  static Future<StreamSubscription<R>> callEntityStreamDirectly<T, R>({
    InvocationParameters parameters = InvocationParameters.emptry,
    required Future<Stream<R>> Function(T serv, InvocationParameters para) function,
    bool cancelOnError = false,
    void Function(R)? onListen,
    void Function()? onDone,
    void Function(Object error, [StackTrace? stackTrace])? onError,
  }) async =>
      (await instance.callEntityStream<T, R>(function: function, parameters: parameters, cancelOnError: cancelOnError)).listen(
        onListen,
        onDone: onDone,
        onError: onError,
        cancelOnError: cancelOnError,
      );
}
