import 'package:maxi_library/src/reflection/interfaces/ideclaration_reflector.dart';

mixin ISetterReflector on IDeclarationReflector {
  void setValue({required dynamic instance, required dynamic newValue, bool beforeVerifying = true});
}
