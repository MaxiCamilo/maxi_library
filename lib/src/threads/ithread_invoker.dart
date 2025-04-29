import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

mixin IThreadInvoker {
  int get threadID;

  Type? get entityType;

  bool get isServer;

  Future<T?> getEntity<T extends Object>();
  Future<void> setEntity(newEnity);

  Future<IThreadInvokeInstance> mountEntity<T extends Object>({required T entity, bool ifExistsOmit = true});
  Future<IThreadInvokeInstance?> getEntityInstance<T extends Object>();
  Future<IThreadInvokeInstance?> getIDInstance({required int id});

  Future<R> callFunction<R>({required InvocationParameters parameters, required FutureOr<R> Function(InvocationContext p1) function});
  Future<Stream<R>> callStream<R>({required InvocationParameters parameters, required FutureOr<Stream<R>> Function(InvocationContext p1) function});

  Future<R> callEntityFunction<T extends Object, R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(T, InvocationContext) function});
  Future<Stream<R>> callEntityStream<T extends Object, R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<Stream<R>> Function(T, InvocationContext) function});

  Future<R> callFunctionOnTheServer<R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(InvocationContext) function});
  Future<Stream<R>> callStreamOnTheServer<R>({required InvocationParameters parameters, required FutureOr<Stream<R>> Function(InvocationContext p1) function});

  Future<R> callBackgroundFunction<R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(InvocationContext para) function});
  Future<Stream<R>> callBackgroundStream<R>({required InvocationParameters parameters, required FutureOr<Stream<R>> Function(InvocationContext p1) function});

  Future<IChannel<S, R>> createChannel<R, S>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<void> Function(InvocationContext context, IChannel<R, S> channel) function});
  Future<IChannel<S, R>> createEntityChannel<T extends Object, R, S>(
      {InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<void> Function(T entity, InvocationContext context, IChannel<R, S> channel) function});
  Future<IChannel<S, R>> callBackgroundChannel<R, S>({required InvocationParameters parameters, required FutureOr<void> Function(InvocationContext context, IChannel<R, S> channel) function});
}
