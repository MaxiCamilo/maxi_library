import 'package:maxi_library/src/reflection/implementatios/fixed_parameter.dart';
import 'package:maxi_library/src/reflection/implementatios/named_parameter.dart';
import 'package:maxi_library/src/reflection/interfaces/ireflection_type.dart';

mixin IMethodReflection {
  List get annotations;

  String get name;
  IReflectionType get returnType;
  bool get isStatic;
  bool get isConstructor;

  List<FixedParameter> get fixedParametes;
  List<NamedParameter> get namedParametes;

  dynamic callMethod({required dynamic instance, required List fixedParametersValues, required Map<String, dynamic> namedParametesValues, bool tryAccommodateParameters = true});
}
