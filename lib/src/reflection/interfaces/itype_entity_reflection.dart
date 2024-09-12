import 'package:maxi_library/src/reflection/interfaces/ientity_framework.dart';
import 'package:maxi_library/src/reflection/interfaces/itype_class_reflection.dart';

mixin ITypeEntityReflection on ITypeClassReflection, IEntityFramework {
  String serializeToJson({required dynamic value, bool setTypeValue = false});

  dynamic interpretationFromJson({
    required String rawJson,
    bool enableCustomInterpretation = true,
    bool verify = true,
  });
}
