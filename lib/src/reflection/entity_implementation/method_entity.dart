import 'package:maxi_library/export_reflectors.dart';
import 'package:maxi_library/src/reflection/templates/reflected_method_template.dart';

class MethodEntity<T, R> extends ReflectedMethodTemplate {
  final GeneratedReflectedMethod<T, R> method;

  @override
  late final Oration description;

  MethodEntity._({
    required this.method,
    required super.annotations,
    required super.fixedParametes,
    required super.isStatic,
    required super.name,
    required super.namedParametes,
    required super.reflectedType,
  }) {
    description = Description.searchDescription(annotations: annotations);
  }

  static MethodEntity<T, R> make<T, R>({required GeneratedReflectedMethod<T, R> method}) {
    return MethodEntity<T, R>._(
      method: method,
      annotations: method.annotations,
      isStatic: method.isStatic,
      name: method.name,
      reflectedType: ReflectionManager.getReflectionType(method.typeReturn, annotations: method.annotations),
      fixedParametes: method.fixedParameters.map((x) => x.generateForReflectedInstance()).toList(),
      namedParametes: method.namedParameters.map((x) => x.generateForReflectedInstance()).toList(),
    );
  }

  @override
  callMethodImplementation({required instance, required List fixedParametersValues, required Map<String, dynamic> namedParametesValues}) {
    return method.callMethod(entity: instance, fixedValues: fixedParametersValues, namedValues: namedParametesValues);
  }

  @override
  callMethodImplementationWithoutParameters({required instance}) {
    return method.callMethod(entity: instance, fixedValues: const [], namedValues: const {});
  }

  @override
  bool get isConstructor => method.methodType == MethodDetectedType.buildMethod || method.methodType == MethodDetectedType.factoryMethod;

  @override
  bool get isGetter => method.methodType == MethodDetectedType.getMehtod;

  @override
  bool get isSetter => method.methodType == MethodDetectedType.setMethod;
}
