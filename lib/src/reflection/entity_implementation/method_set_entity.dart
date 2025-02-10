import 'package:maxi_library/export_reflectors.dart';
import 'package:maxi_library/src/reflection/interfaces/isetter_reflector.dart';

class MethodSetEntity<T, R> with IDeclarationReflector, ISetterReflector {
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

  late final CustomInterpretation? customInterpretation;

  @override
  late final Oration description;

  MethodSetEntity._({
    required this.method,
    required this.annotations,
    required this.formalName,
    required this.isStatic,
    required this.name,
    required this.reflectedType,
    required this.validators,
  }) {
    customInterpretation = annotations.selectByType<CustomInterpretation>();
    description = Description.searchDescription(annotations: annotations);
  }

  static MethodSetEntity<T, R> make<T, R>({required GeneratedReflectedMethod<T, R> method}) {
    assert(method.methodType == MethodDetectedType.setMethod);
    return MethodSetEntity<T, R>._(
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
  void setValue({required instance, required newValue, bool beforeVerifying = true}) {
    if (customInterpretation != null) {
      newValue = customInterpretation!.performInterpretation(value: newValue, declaration: this);
    } else {
      newValue = reflectedType.convertObject(newValue);
    }

    method.callMethod(entity: instance, fixedValues: [newValue], namedValues: const {});
  }
}
