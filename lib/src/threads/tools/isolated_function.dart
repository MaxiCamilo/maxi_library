import 'package:maxi_library/maxi_library.dart';

class IsolatedFunction<S extends Object, T> {
  final Future<T> Function(S serv, InvocationParameters para) function;

  const IsolatedFunction({required this.function});

  Future<T> execute([InvocationParameters parameters = InvocationParameters.emptry]) {
    return ThreadManager.callEntityFunction<S, T>(
      parameters: InvocationParameters.clone(parameters)..fixedParameters.add(function),
      function: _executeInThread<S, T>,
    );
  }

  static Future<T> _executeInThread<S, T>(S serv, InvocationParameters para) {
    final function = para.fixedParameters.last as Future<T> Function(S, InvocationParameters);
    return function(serv, para);
  }
}
