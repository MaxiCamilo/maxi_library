import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class ExecuteFunctionalityOnSpecificObject<I, R, S extends Object, O> with InteractableFunctionality<I, R> {
  final FutureOr<O> Function(S, InvocationParameters) operatorGetter;
  final FutureOr<InteractableFunctionality<I, R>> Function(O, InvocationParameters) functionalityGetter;
  final InvocationParameters parameters;

  const ExecuteFunctionalityOnSpecificObject({required this.operatorGetter, required this.functionalityGetter, required this.parameters});

  @override
  Future<R> runFunctionality({required InteractableFunctionalityExecutor<I, R> manager}) async {
    final entity = await volatileAsync(detail: const Oration(message: 'Entity is not null'), function: () async => (await ThreadManager.instance.getEntity<S>())!);

    final entityOperator = await operatorGetter(entity, parameters);
    final functionality = await functionalityGetter(entityOperator, parameters);

    return await functionality.joinExecutor(manager);
  }
}
