import 'dart:async';

import 'package:maxi_library/export_reflectors.dart';
import 'package:meta/meta.dart';

mixin IFunctionality<T> {
  T runFunctionality();

  Future<T> runInBackgrond() async {
    return await ThreadManager.callBackgroundFunction(parameters: InvocationParameters.only(this), function: _runInBackgroud<T, IFunctionality<T>>);
  }

  static Future<R> _runInBackgroud<R, T extends IFunctionality<R>>(InvocationParameters parameter) async {
    final functionality = parameter.firts<IFunctionality<R>>();
    final result = functionality.runFunctionality();

    if (result is Future) {
      throw '¡BAD OPTION! USE runFutureInBackgrond()';
    } else {
      return result;
    }
  }
}

mixin IFunctionalityService<S extends Object, R> implements IFunctionality<Future<R>> {
  @protected
  FutureOr<R> runInService(S service, InvocationParameters parameters);

  @override
  Future<R> runFunctionality() {
    return ThreadManager.callEntityFunction<S, R>(parameters: InvocationParameters.only(this), function: _executeFunctionalityInService<S, R>);
  }

  @override
  Future<Future<R>> runInBackgrond() async {
    return runFunctionality();
  }

  static Future<R> _executeFunctionalityInService<S extends Object, R>(S service, InvocationParameters parameters) async {
    final functionality = parameters.firts<IFunctionalityService<S, R>>();
    return await functionality.runInService(service, parameters);
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

  Future<F> runFutureInBackgrond() {
    return ThreadManager.callBackgroundFunction(parameters: InvocationParameters.only(this), function: _runInBackgroud<F, IFunctionality<Future<F>>>);
  }

  static Future<R> _runInBackgroud<R, T extends IFunctionality<Future<R>>>(InvocationParameters parameter) async {
    final functionality = parameter.firts<IFunctionality<Future<R>>>();
    return await functionality.runFunctionality();
  }
}

extension IFunctionalityStreamExtension<T> on IFunctionality<Stream<T>> {
  Future<Stream<T>> runStreamInBackgrond() async {
    return ThreadManager.callBackgroundStream(function: _runStreamInBackgroud<T>, parameters: InvocationParameters.only(this));
  }

  static Future<Stream<R>> _runStreamInBackgroud<R>(InvocationParameters parameter) async {
    final functionality = parameter.firts<IFunctionality<Stream<R>>>();
    return functionality.runFunctionality();
  }
}
