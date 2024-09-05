import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/old_implementation/reflector_standard_utilities.dart';
import 'package:maxi_library/src/reflection/templates/reflected_method_template.dart';

class MethodReflectorStandard extends ReflectedMethodTemplate {
  final Reflectable reflectable;
  final ClassMirror classMirror;
  final MethodMirror methodMirror;

  @override
  bool get isConstructor => methodMirror.isConstructor;

  @override
  bool get isGetter => methodMirror.isGetter;

  @override
  bool get isSetter => methodMirror.isSetter;

  late final CustomSerialization? customSerialization;

  MethodReflectorStandard._(
      {required super.annotations,
      required super.fixedParametes,
      required super.isStatic,
      required super.name,
      required super.namedParametes,
      required super.reflectedType,
      required this.classMirror,
      required this.methodMirror,
      required this.reflectable}) {
    customSerialization = methodMirror.metadata.selectByType<CustomSerialization>();
  }

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
          annotations: item.metadata,
        ));
      } else {
        fixedParametes.add(FixedParameter(
          isOptional: item.isOptional,
          name: item.simpleName,
          annotations: item.metadata,
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
      isStatic: methodMirror.isStatic || methodMirror.isConstructor || methodMirror.isFactoryConstructor,
      name: name,
      namedParametes: namedParametes,
      reflectedType: ReflectionManager.getReflectionType(methodMirror.reflectedReturnType, annotations: methodMirror.metadata),
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

  @override
  String toString() => 'Method $name ($reflectedType)';

  callMethodImplementationWithGetter({required instance}) {
    if (isStatic) {
      return ReflectorStandardUtilities.getStaticInstance(reflect: reflectable, type: classMirror.dynamicReflectedType).invokeGetter(name);
    } else {
      return ReflectorStandardUtilities.getInstance(reflect: reflectable, object: instance).invokeGetter(name);
    }
  }

  @override
  callMethodImplementationWithoutParameters({required instance}) {
    late final dynamic value;

    if (isGetter) {
      value = callMethodImplementationWithGetter(instance: instance);
    } else if (isStatic) {
      value = ReflectorStandardUtilities.getStaticInstance(reflect: reflectable, type: classMirror.dynamicReflectedType).invoke(
        name,
        const [],
        const {},
      );
    } else {
      value = ReflectorStandardUtilities.getInstance(reflect: reflectable, object: instance).invoke(
        name,
        const [],
        const {},
      );
    }

    if (customSerialization != null) {
      return customSerialization!.performSerialization(entity: value, declaration: this);
    } else {
      return value;
    }
  }
}
