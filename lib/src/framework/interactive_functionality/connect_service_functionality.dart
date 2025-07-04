import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class ConnectServiceFunctionality<S extends Object, I, R> with InteractiveFunctionality<I, R>, InteractiveServiceFunctionality<S, I, R> {
  final InvocationParameters parameters;
  final FutureOr<InteractiveFunctionality<I, R>> Function(S, InvocationParameters) functionalityGetter;

  const ConnectServiceFunctionality({required this.parameters, required this.functionalityGetter});

  @override
  Future<R> runFunctionalityInService({required InteractiveFunctionalityExecutor<I, R> manager, required S service}) async {
    final functionality = await manager.waitFutureFunction(function: () async => await functionalityGetter(service, parameters));
    await manager.continueOtherFutures();

    return await functionality.joinExecutor(manager);
  }
}
