import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

mixin ThreadManager {
  static bool get instanceDefined => _instance != null;
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
        message: Oration(message: '[ThreadManager] Thread manager has already been initialized'),
      );
    }

    _instance = newInvoker;
  }

  static Future<IThreadInvokeInstance> getEntityInstance<T extends Object>() => volatileAsync(detail: Oration(message: 'entity %1 was not mounted'), function: () async => (await instance.getEntityInstance<T>())!);

  static Future<R> callEntityFunction<T extends Object, R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(T serv, InvocationParameters para) function}) =>
      instance.callEntityFunction<T, R>(function: function, parameters: parameters);
  static Future<Stream<R>> callEntityStream<T extends Object, R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<Stream<R>> Function(T serv, InvocationParameters para) function}) =>
      instance.callEntityStream<T, R>(function: function, parameters: parameters);

  static Future<IThreadInvokeInstance> mountEntity<T extends Object>({required T entity, bool ifExistsOmit = true}) => instance.mountEntity<T>(entity: entity, ifExistsOmit: ifExistsOmit);

  static void addThreadInitializer({required IThreadInitializer initializer}) {
    if (instance is IThreadManagerServer) {
      (instance as IThreadManagerServer).addThreadInitializer(initializer: initializer);
    }
  }

  static Future<StreamSubscription<R>> callEntityStreamDirectly<T extends Object, R>({
    InvocationParameters parameters = InvocationParameters.emptry,
    required FutureOr<Stream<R>> Function(T serv, InvocationParameters para) function,
    bool cancelOnError = false,
    void Function(R)? onListen,
    void Function()? onDone,
    void Function(Object error, [StackTrace? stackTrace])? onError,
  }) async =>
      (await instance.callEntityStream<T, R>(function: function, parameters: parameters)).listen(
        onListen,
        onDone: onDone,
        onError: onError,
        cancelOnError: cancelOnError,
      );

  static Future<R> callBackgroundFunction<R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(InvocationContext para) function}) =>
      instance.callBackgroundFunction<R>(function: function, parameters: parameters);

  static Future<Stream<R>> callBackgroundStream<R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<Stream<R>> Function(InvocationContext para) function}) =>
      instance.callBackgroundStream<R>(function: function, parameters: parameters);

  static Future<IPipe<S, R>> createEntityPipe<T extends Object, R, S>({
    InvocationParameters parameters = InvocationParameters.emptry,
    required FutureOr<void> Function(T entity, InvocationContext context, IPipe<R, S> pipe) function,
  }) =>
      instance.createEntityPipe<T, R, S>(function: function, parameters: parameters);
}
