import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/interfaces/igetter_reflector.dart';
import 'package:maxi_library/src/reflection/interfaces/isetter_reflector.dart';

mixin ITypeClassReflection on IReflectionType, IDeclarationReflector {
  List<IFieldReflection> get fields;
  List<IMethodReflection> get methods;
  List<ITypeEntityReflection> get inheritance;

  List<IGetterReflector> get getters;
  List<ISetterReflector> get setters;
  ITypeEntityReflection? get baseClass;

  List<IMethodReflection> get constructors;

  bool get hasDefaultConstructor;

  bool get isAbstract;

  int generateHashCode({required dynamic item, required bool addName});

  bool areSame({required dynamic first, required dynamic second});

  dynamic buildEntity({
    String selectedBuild = '',
    List fixedParametersValues = const [],
    Map<String, dynamic> namedParametersValues = const {},
    bool tryAccommodateParameters = true,
    bool useCustomConstructor = true,
  });

  void changeFieldValue({
    required String name,
    required dynamic instance,
    required dynamic newValue,
  });

  dynamic getFieldValue({
    required String name,
    required dynamic instance,
  });

  dynamic getProperty({
    required String name,
    required dynamic instance,
  });

  void changeProperty({
    required String name,
    required dynamic instance,
    required dynamic newValue,
  });

  dynamic callMethod({
    required String name,
    required dynamic instance,
    List fixedParametersValues = const [],
    Map<String, dynamic> namedParametesValues = const {},
    bool tryAccommodateParameters = true,
  });
}
