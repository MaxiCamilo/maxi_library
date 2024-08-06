import 'package:maxi_library/src/reflection/interfaces/ireflection_type.dart';

mixin IFieldReflection {
  List get annotations;

  String get name;
  IReflectionType get fieldType;
  bool get isStatic;
  bool get onlyRead;

  dynamic getValue({required dynamic instance});

  void setValue({required dynamic instance, required dynamic newValue});


}
