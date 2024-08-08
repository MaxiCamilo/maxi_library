import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/interfaces/igetter_reflector.dart';
import 'package:maxi_library/src/reflection/interfaces/isetter_reflector.dart';

mixin IFieldReflection on IDeclarationReflector, IGetterReflector, ISetterReflector {
  bool get onlyRead;

  bool get isRequired;

  NegativeResult? checkValueIsCorrect({required instance}) {
    final value = getValue(instance: instance);
    return verifyValue(value: value);
  }
}
