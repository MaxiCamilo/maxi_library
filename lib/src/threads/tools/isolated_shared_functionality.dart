import 'dart:async';

import 'package:maxi_library/export_reflectors.dart';
import 'package:maxi_library/src/threads/internal/isolated_shared_functionality_executor.dart';
import 'package:maxi_library/src/threads/internal/isolated_shared_functionality_instance.dart';
import 'package:maxi_library/src/threads/internal/shared_values_service.dart';
import 'package:meta/meta.dart';

class IsolatedSharedFunctionality<I, R> with StartableFunctionality, PaternalFunctionality {
  final String name;
  final InteractiveFunctionality<I, R>? definedFunctionality;

  IsolatedSharedFunctionality({required this.name, this.definedFunctionality});

  @internal
  Future<T> executeFromInstance<T>({
    InvocationParameters parameters = InvocationParameters.emptry,
    required FutureOr<T> Function(IsolatedSharedFunctionalityInstance<I, R> inst, InvocationParameters para) function,
  }) async {
    await initialize();
    return await ThreadManager.callEntityFunction<SharedValuesService, T>(
      parameters: InvocationParameters.list([name, function, InvocationParameters.clone(parameters)]),
      function: _executeFromInstanceStatic<I, R, T>,
    );
  }

  static Future<T> _executeFromInstanceStatic<I, R, T>(SharedValuesService service, InvocationParameters parameters) async {
    final item = service.getFunctionality<I, R>(name: parameters.firts<String>());
    return await parameters.second<FutureOr<T> Function(IsolatedSharedFunctionalityInstance<I, R>, InvocationParameters)>()(item, parameters.third<InvocationParameters>());
  }

  @override
  Future<void> initializeFunctionality() async {
    await SharedValuesService.mountService();

    if (!await ThreadManager.callEntityFunction<SharedValuesService, bool>(
      parameters: InvocationParameters.only(name),
      function: (serv, para) => serv.existsFunctionality<I, R>(name: para.firts<String>()),
    )) {
      if (definedFunctionality == null) {
        throw NegativeResult(
          identifier: NegativeResultCodes.nonExistent,
          message: Oration(
            message: 'The shared functionality %1 was not defined',
            textParts: [name],
          ),
        );
      } else {
        await ThreadManager.callEntityFunction<SharedValuesService, void>(
          parameters: InvocationParameters.list([name, definedFunctionality]),
          function: (serv, para) => serv.defineOrChangeSharedFunctionality(
            name: para.firts<String>(),
            functionality: para.second<InteractiveFunctionality<I, R>>(),
          ),
        );
      }
    }
  }

  Stream<I> get itemStream async* {
    await initialize();
    yield* ThreadManager.callEntityStreamSync<SharedValuesService, I>(
      parameters: InvocationParameters.list([
        name,
      ]),
      function: (serv, para) {
        return serv.getFunctionality<I, R>(name: para.firts<String>()).itemStream;
      },
    );
  }

  InteractiveFunctionality<I, R> execute({
    required bool reRunIfActive,
    bool cancelAlsoOnInstance = false,
  }) =>
      IsolatedSharedFunctionalityExecutor<I, R>(
        mainOperator: this,
        reRunIfActive: reRunIfActive,
        cancelAlsoOnInstance: cancelAlsoOnInstance,
      );
}
