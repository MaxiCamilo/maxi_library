import 'package:maxi_library/export_reflectors.dart';
import 'package:maxi_library/src/threads/internal/shared_values_service.dart';

class IsolatedSharedFunctionality<I, R> with StartableFunctionality, PaternalFunctionality {
  final String name;
  final InteractiveFunctionality<I, R>? definedFunctionality;

  IsolatedSharedFunctionality({required this.name, this.definedFunctionality});

  @override
  Future<void> initializeFunctionality() async {
    await SharedValuesService.mountService();

    if (!await ThreadManager.callEntityFunction<SharedValuesService, bool>(
      parameters: InvocationParameters.only(name),
      function: (serv, para) => serv.existsFunctionality(name: para.firts<String>()),
    )) {
      if (definedFunctionality == null) {
        
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
}
