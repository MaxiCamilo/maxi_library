import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/interfaces/igetter_reflector.dart';
import 'package:maxi_library/src/reflection/interfaces/isetter_reflector.dart';

mixin IFieldReflection on IDeclarationReflector, IGetterReflector, ISetterReflector {
  bool get onlyRead;

  bool get isRequired;

  bool get isPrimaryKey;

  bool get isEssentialKey;

  bool get isUnique;

  String get nameInLowerCase;

  bool areSame({required dynamic first, required dynamic second});

  NegativeResult? checkValueIsCorrect({required instance}) {
    final value = getValue(instance: instance);
    return verifyValue(value: value, parentEntity: instance);
  }
}
