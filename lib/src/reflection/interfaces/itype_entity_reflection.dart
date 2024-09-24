import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/interfaces/ientity_framework.dart';
import 'package:maxi_library/src/reflection/interfaces/itype_class_reflection.dart';

mixin ITypeEntityReflection on ITypeClassReflection, IEntityFramework {
  String serializeToJson({required dynamic value, bool setTypeValue = false});

  dynamic interpretationFromJson({
    required String rawJson,
    required bool tryToCorrectNames,
    bool enableCustomInterpretation = true,
    bool verify = true,
    bool acceptZeroIdentifier = true,
    bool primaryKeyMustBePresent = true,
    bool essentialKeysMustBePresent = true,
  });

  
}
