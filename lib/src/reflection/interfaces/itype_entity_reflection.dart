import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/interfaces/ientity_framework.dart';
import 'package:maxi_library/src/reflection/interfaces/itype_class_reflection.dart';

mixin ITypeEntityReflection on ITypeClassReflection, IEntityFramework {
  String serializeToJson({required dynamic value});

  dynamic interpretationFromJson({
    required String rawJson,
    bool enableCustomInterpretation = true,
    bool verify = true,
  });
}
