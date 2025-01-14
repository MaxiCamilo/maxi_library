import 'dart:async';

import 'package:maxi_library/export_reflectors.dart';
import 'package:meta/meta.dart';

mixin IFunctionality<T> {
  T runFunctionality();
}

mixin IFunctionalityService<S extends Object, R> implements IFunctionality<Future<R>> {
  @protected
  FutureOr<R> runInService(S service, InvocationParameters parameters);

  @override
  Future<R> runFunctionality() {
    return ThreadManager.callEntityFunction<S, R>(parameters: InvocationParameters.only(this), function: _executeFunctionalityInService<S, R>);
  }

  static Future<R> _executeFunctionalityInService<S extends Object, R>(S service, InvocationParameters parameters) async {
    final functionality = parameters.firts<IFunctionalityService<S, R>>();
    return await functionality.runInService(service, parameters);
  }
}

mixin IFunctionalityStreamService<S extends Object, T extends StreamState> implements IFunctionality<Stream<T>> {
  @protected
  Stream<T> runInService(S service, InvocationParameters parameters);

  

  @override
  Stream<T> runFunctionality() async* {
    yield* await ThreadManager.callEntityStream<S, T>(parameters: InvocationParameters.only(this), function: _executeFunctionalityInService<S, T>);
  }

  static Stream<T> _executeFunctionalityInService<S extends Object, T extends StreamState>(S service, InvocationParameters parameters) {
    final functionality = parameters.firts<IFunctionalityStreamService<S, T>>();
    return functionality.runInService(service, parameters);
  }
}

extension IFunctionalityFuture<F> on IFunctionality<Future<F>> {
  Future<F> executeInService<S extends Object>() async {
    return ThreadManager.callEntityFunction<S, F>(parameters: InvocationParameters.only(this), function: _executeInService<S, F>);
  }

  static Future<F> _executeInService<S, F>(S service, InvocationParameters parameters) {
    final functionality = parameters.firts<IFunctionality<Future<F>>>();

    return functionality.runFunctionality();
  }
}
