import 'package:maxi_library/maxi_library.dart';

mixin IMethodReflection on IDeclarationReflector {
  bool get isConstructor;

  List<FixedParameter> get fixedParametes;
  List<NamedParameter> get namedParametes;

  dynamic callMethod({required dynamic instance, required List fixedParametersValues, required Map<String, dynamic> namedParametesValues, bool tryAccommodateParameters = true});
}
