import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/implementatios/fixed_parameter.dart';
import 'package:maxi_library/src/reflection/implementatios/named_parameter.dart';
import 'package:maxi_library/src/reflection/standard/reflector_standard_utilities.dart';
import 'package:maxi_library/src/reflection/templates/template_method_reflection.dart';
import 'package:reflectable/reflectable.dart';

class MethodReflectorStandard extends TemplateMethodReflection {
  final Reflectable reflectable;
  final ClassMirror classMirror;
  final MethodMirror methodMirror;

  @override
  bool get isConstructor => methodMirror.isConstructor;

  MethodReflectorStandard._(
      {required super.annotations,
      required super.fixedParametes,
      required super.isStatic,
      required super.name,
      required super.namedParametes,
      required super.returnType,
      required this.classMirror,
      required this.methodMirror,
      required this.reflectable});

  factory MethodReflectorStandard.make({required Reflectable reflectable, required ClassMirror classMirror, required MethodMirror methodMirror}) {
    final fixedParametes = <FixedParameter>[];
    final namedParametes = <NamedParameter>[];

    late String name;
    if (methodMirror.isConstructor) {
      final partido = methodMirror.simpleName.split('.');
      name = partido.length == 1 ? '' : partido.last;
    } else {
      name = methodMirror.simpleName;
    }

    int i = 0;

    for (final item in methodMirror.parameters) {
      if (item.isNamed) {
        namedParametes.add(NamedParameter(
          isRequierd: !item.isOptional,
          name: item.simpleName,
          optinalValue: item.isOptional ? item.defaultValue : null,
          type: item.dynamicReflectedType,
        ));
      } else {
        fixedParametes.add(FixedParameter(
          isOptional: item.isOptional,
          name: item.simpleName,
          position: i,
          optionalValue: item.isOptional ? item.defaultValue : null,
          type: item.dynamicReflectedType,
        ));
        i = i + 1;
      }
    }

    return MethodReflectorStandard._(
      annotations: methodMirror.metadata,
      fixedParametes: fixedParametes,
      isStatic: methodMirror.isStatic,
      name: name,
      namedParametes: namedParametes,
      returnType: ReflectionManager.getReflectionType(methodMirror.reflectedReturnType),
      classMirror: classMirror,
      methodMirror: methodMirror,
      reflectable: reflectable,
    );
  }

  @override
  callMethodImplementation({required instance, required List fixedParametersValues, required Map<String, dynamic> namedParametesValues}) {
    if (isConstructor) {
      return classMirror.newInstance(name, fixedParametersValues, namedParametesValues.map((key, value) => MapEntry(Symbol(key), value)));
    } else if (isStatic) {
      return ReflectorStandardUtilities.getStaticInstance(reflect: reflectable, type: classMirror.dynamicReflectedType).invoke(
        name,
        fixedParametersValues,
        namedParametesValues.map((key, value) => MapEntry(Symbol(key), value)),
      );
    } else {
      return ReflectorStandardUtilities.getInstance(reflect: reflectable, object: instance).invoke(
        name,
        fixedParametersValues,
        namedParametesValues.map((key, value) => MapEntry(Symbol(key), value)),
      );
    }
  }
}
