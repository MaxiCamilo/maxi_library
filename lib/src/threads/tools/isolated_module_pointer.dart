import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/standars/execute_functionality_on_specific_object.dart';

class IsolatedModulePointer<S extends Object, T> {
  final FutureOr<T> Function(S serv, InvocationParameters para) getterModule;

  const IsolatedModulePointer({required this.getterModule});

  Future<R> execute<R>({required FutureOr<R> Function(T entity, InvocationParameters para) function, InvocationParameters parameters = InvocationParameters.emptry}) {
    return ThreadManager.callEntityFunction<S, R>(
      parameters: InvocationParameters.clone(parameters)
        ..fixedParameters.add(function)
        ..fixedParameters.add(getterModule),
      function: _executeInThread<S, T, R>,
    );
  }

  Stream<R> getStream<R>({required FutureOr<Stream<R>> Function(T item, InvocationParameters para) function, InvocationParameters parameters = InvocationParameters.emptry}) async* {
    final stream = await ThreadManager.callEntityStream<S, R>(
      parameters: InvocationParameters.clone(parameters)
        ..fixedParameters.add(function)
        ..fixedParameters.add(getterModule),
      function: _executeStreamInThread<S, T, R>,
    );
    yield* stream;
  }

  InteractableFunctionalityOperator<I, R> executeFunctionality<I, R>({
    required FutureOr<InteractableFunctionality<I, R>> Function(T item, InvocationParameters para) function,
    InvocationParameters parameters = InvocationParameters.emptry,
  }) {
    return ExecuteFunctionalityOnSpecificObject<I, R, S, T>(
      operatorGetter: getterModule,
      functionalityGetter: function,
      parameters: parameters,
    ).runInService<S>();
  }

  static Future<R> _executeInThread<S, T, R>(S serv, InvocationParameters para) async {
    final getterModule = para.fixedParameters[para.fixedParameters.length - 1] as FutureOr<T> Function(S, InvocationParameters);
    final module = await getterModule(serv, para);

    final function = para.fixedParameters[para.fixedParameters.length - 2] as FutureOr<R> Function(T, InvocationParameters);
    return await function(module, para);
  }

  static Future<Stream<R>> _executeStreamInThread<S, T, R>(S serv, InvocationParameters para) async {
    final getterModule = para.fixedParameters[para.fixedParameters.length - 1] as FutureOr<T> Function(S, InvocationParameters);
    final module = await getterModule(serv, para);

    final function = para.fixedParameters[para.fixedParameters.length - 2] as FutureOr<Stream<R>> Function(T, InvocationParameters);
    return await function(module, para);
  }
}
