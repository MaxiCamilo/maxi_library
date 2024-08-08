import 'package:maxi_library/src/reflection/implementatios/fixed_parameter.dart';
import 'package:maxi_library/src/reflection/implementatios/named_parameter.dart';
import 'package:maxi_library/src/reflection/interfaces/ideclaration_reflector.dart';

mixin IMethodReflection on IDeclarationReflector {
  bool get isConstructor;

  List<FixedParameter> get fixedParametes;
  List<NamedParameter> get namedParametes;

  dynamic callMethod({required dynamic instance, required List fixedParametersValues, required Map<String, dynamic> namedParametesValues, bool tryAccommodateParameters = true});
}
