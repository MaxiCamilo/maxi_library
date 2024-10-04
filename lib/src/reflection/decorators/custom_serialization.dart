import 'package:maxi_library/src/reflection/interfaces/ideclaration_reflector.dart';

mixin CustomSerialization {
  dynamic performSerialization({
    required dynamic entity,
    required IDeclarationReflector declaration,
    bool onlyModificable = true,
    bool allowStaticFields = false,
  });
}
