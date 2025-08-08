import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/build/generators/generated_reflected_field.dart';
import 'package:maxi_library/src/reflection/interfaces/igetter_reflector.dart';
import 'package:maxi_library/src/reflection/interfaces/isetter_reflector.dart';

class FieldEntity<T, R> with IDeclarationReflector, IGetterReflector, ISetterReflector, IFieldReflection {
  final GeneratedReflectedField<T, R> field;

  @override
  final List annotations;

  @override
  final Oration formalName;

  @override
  final bool isRequired;

  @override
  final bool isStatic;

  @override
  final String name;

  @override
  final bool onlyRead;

  @override
  final IReflectionType reflectedType;

  @override
  final List<ValueValidator> validators;

  @override
  late final bool isPrimaryKey;

  @override
  late final bool isEssentialKey;

  @override
  late final bool isUnique;

  @override
  late final String nameInLowerCase;

  late final CustomInterpretation? customInterpretation;

  late final CustomSerialization? customSerialization;

  @override
  late final Oration description;

  FieldEntity._({
    required this.field,
    required this.annotations,
    required this.formalName,
    required this.isRequired,
    required this.isStatic,
    required this.name,
    required this.onlyRead,
    required this.reflectedType,
    required this.validators,
  }) {
    description = Description.searchDescription(annotations: annotations);
    customInterpretation = annotations.selectByType<CustomInterpretation>();
    customSerialization = annotations.selectByType<CustomSerialization>();

    isPrimaryKey = annotations.selectByType<PrimaryKey>() != null;
    isEssentialKey = annotations.selectByType<EssentialKey>() != null;
    isUnique = annotations.selectByType<UniqueProperty>() != null;
    nameInLowerCase = name.toLowerCase();
  }

  static FieldEntity<T, R> make<T, R>({required GeneratedReflectedField<T, R> field}) {
    return FieldEntity<T, R>._(
      field: field,
      annotations: field.annotations,
      formalName: FormalName.searchFormalName(realName: Oration(message: field.name), annotations: field.annotations),
      isRequired: field.annotations.any((x) => x is EssentialKey),
      isStatic: field.isStatic || field.isConst,
      name: field.name,
      onlyRead: (field.isFinal && !field.isLate) || field.isConst,
      reflectedType: ReflectionManager.getReflectionType(field.typeReturn, annotations: field.annotations),
      validators: field.annotations.whereType<ValueValidator>().toList(),
    );
  }

  @override
  getValue({required instance}) {
    late final dynamic value;

    value = field.getValue(entity: instance);

    if (customSerialization != null) {
      return customSerialization!.performSerialization(value: value, declaration: this);
    } else {
      return value;
    }
  }

  @override
  void setValue({required instance, required newValue, bool beforeVerifying = true}) {
    if (customInterpretation != null) {
      newValue = customInterpretation!.performInterpretation(value: newValue, declaration: this);
    } else {
      newValue = reflectedType.convertObject(newValue);
    }

    if (beforeVerifying) {
      verifyValueDirectly(value: newValue, parentEntity: instance);
    }

    if (field is GeneratedReflectedModifiableField<T, R>) {
      (field as GeneratedReflectedModifiableField<T, R>).setValue(entity: instance, newValue: newValue);
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: Oration(message: 'Field %1 is not modifiable', textParts: [name]),
      );
    }
  }

  @override
  bool areSame({required first, required second}) {
    final firstValue = getValue(instance: first);
    final secondValue = getValue(instance: second);

    return ReflectionManager.areSame(first: firstValue, second: secondValue);
  }
}
