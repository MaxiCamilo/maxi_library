import 'package:maxi_library/export_reflectors.dart';
import 'package:maxi_library/src/reflection/interfaces/igetter_reflector.dart';

class MethodGetEntity<T, R> with IDeclarationReflector, IGetterReflector {
  final GeneratedReflectedMethod<T, R> method;

  @override
  final List annotations;

  @override
  final Oration formalName;

  @override
  final bool isStatic;

  @override
  final String name;

  @override
  final IReflectionType reflectedType;

  @override
  final List<ValueValidator> validators;

  late final CustomSerialization? customSerialization;

  @override
  late final Oration description;

  MethodGetEntity._({
    required this.method,
    required this.annotations,
    required this.formalName,
    required this.isStatic,
    required this.name,
    required this.reflectedType,
    required this.validators,
  }) {
    customSerialization = annotations.selectByType<CustomSerialization>();
    description = Description.searchDescription(annotations: annotations);
  }

  static MethodGetEntity<T, R> make<T, R>({required GeneratedReflectedMethod<T, R> method}) {
    assert(method.methodType == MethodDetectedType.getMehtod);
    return MethodGetEntity<T, R>._(
      method: method,
      annotations: method.annotations,
      isStatic: method.isStatic,
      name: method.name,
      reflectedType: ReflectionManager.getReflectionType(method.typeReturn, annotations: method.annotations),
      validators: method.annotations.whereType<ValueValidator>().toList(),
      formalName: FormalName.searchFormalName(realName: Oration(message: method.name), annotations: method.annotations),
    );
  }

  @override
  getValue({required instance}) {
    final value = method.callMethod(entity: instance, fixedValues: const [], namedValues: const {});

    if (customSerialization == null) {
      return value;
    } else {
      return customSerialization!.performSerialization(entity: value, declaration: this);
    }
  }
}
