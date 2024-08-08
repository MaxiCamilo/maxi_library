import 'package:maxi_library/src/reflection/interfaces/ideclaration_reflector.dart';

mixin IGetterReflector on IDeclarationReflector {
  dynamic getValue({required dynamic instance});
}
