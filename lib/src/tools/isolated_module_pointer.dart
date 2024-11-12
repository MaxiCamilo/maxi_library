import 'package:maxi_library/maxi_library.dart';

class IsolatedModulePointer<S, T> {
  final Future<T> Function(S serv, InvocationParameters para) getterModule;

  const IsolatedModulePointer({required this.getterModule});

  Future<R> execute<R>({required Future<R> Function(T item, InvocationParameters para) function, InvocationParameters parameters = InvocationParameters.emptry}) {
    return ThreadManager.callEntityFunction<S, R>(
      parameters: InvocationParameters.clone(parameters)
        ..fixedParameters.add(function)
        ..fixedParameters.add(getterModule),
      function: _executeInThread<S, T, R>,
    );
  }

  static Future<R> _executeInThread<S, T, R>(S serv, InvocationParameters para) async {
    final getterModule = para.fixedParameters[para.fixedParameters.length - 1] as Future<T> Function(S, InvocationParameters);
    final module = await getterModule(serv, para);

    final function = para.fixedParameters[para.fixedParameters.length - 2] as Future<R> Function(T, InvocationParameters);
    return await function(module, para);
  }
}
