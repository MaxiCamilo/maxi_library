import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

typedef TextableServiceFunctionality<S extends Object, R> = InteractiveServiceFunctionality<S, Oration, R>;
typedef TextableServiceFunctionalityVoid<S extends Object> = InteractiveServiceFunctionality<S, Oration, void>;

mixin InteractiveServiceFunctionality<S extends Object, I, R> on InteractiveFunctionality<I, R> {
  @override
  Future<R> runFunctionality({required InteractiveFunctionalityExecutor<I, R> manager}) async {
    if (ThreadManager.instance.isServer || ThreadManager.instance.entityType != S) {
      /*
      final connection = inService<S>().createOperator()..start();

      manager.onDispose.whenComplete(() => connection.cancel());

      return connection.waitResult(onItem: manager.sendItem);*/
      return await inService<S>().joinExecutor(manager);
    }

    final entity = await ThreadManager.instance.getEntity<S>();
    checkProgrammingFailure(thatChecks: const Oration(message: 'Client thread has an entity'), result: () => entity != null);
    return await runFunctionalityInService(manager: manager, service: entity!);
  }

  FutureOr<R> runFunctionalityInService({required InteractiveFunctionalityExecutor<I, R> manager, required S service});
}
