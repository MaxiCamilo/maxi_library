import 'package:maxi_library/src/reflection/interfaces/ifield_reflection.dart';
import 'package:maxi_library/src/reflection/interfaces/imethod_reflection.dart';
import 'package:maxi_library/src/reflection/interfaces/ireflection_type.dart';

mixin ITypeEntityReflection on IReflectionType {
  List<IFieldReflection> get fields;
  List<IMethodReflection> get methods;
  List<ITypeEntityReflection> get inheritance;
  ITypeEntityReflection? get baseClass;

  List<IMethodReflection> get constructors;

  bool get hasDefaultConstructor;

  bool get isAbstract;

  dynamic buildEntity({String selectedBuild = '', List fixedParametersValues = const [], Map<String, dynamic> namedParametersValues = const {}, bool tryAccommodateParameters = true});

  void changeFieldValue({
    required String name,
    required dynamic instance,
    required dynamic newValue,
  });

  dynamic getFieldValue({
    required String name,
    required dynamic instance,
  });

  dynamic callMethod({
    required String name,
    required dynamic instance,
    required List fixedParametersValues,
    required Map<String, dynamic> namedParametesValues,
    bool tryAccommodateParameters = true,
  });
}
