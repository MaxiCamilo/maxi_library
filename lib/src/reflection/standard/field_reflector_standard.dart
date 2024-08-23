import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/decorators/essential_key.dart';
import 'package:maxi_library/src/reflection/interfaces/ifield_reflection.dart';
import 'package:maxi_library/src/reflection/interfaces/igetter_reflector.dart';
import 'package:maxi_library/src/reflection/interfaces/isetter_reflector.dart';
import 'package:maxi_library/src/reflection/standard/reflector_standard_utilities.dart';

class FieldReflectorStandard with IDeclarationReflector, IGetterReflector, ISetterReflector, IFieldReflection {
  final Reflectable reflectable;
  final ClassMirror classMirror;
  final VariableMirror variableMirror;

  @override
  late final String formalName;

  @override
  late final IReflectionType reflectedType;

  @override
  late final List<ValueValidator> validators;

  @override
  late final bool isRequired;

  FieldReflectorStandard({required this.reflectable, required this.classMirror, required this.variableMirror}) {
    reflectedType = ReflectionManager.getReflectionType(variableMirror.dynamicReflectedType, annotations: variableMirror.metadata);
    formalName = FormalName.searchFormalName(realName: name, annotations: annotations);
    isRequired = variableMirror.metadata.any((x) => x is EssentialKey);

    validators = variableMirror.metadata.whereType<ValueValidator>().toList();
  }

  @override
  List get annotations => variableMirror.metadata;

  @override
  bool get isStatic => variableMirror.isStatic;

  @override
  String get name => variableMirror.simpleName;

  @override
  bool get onlyRead => variableMirror.isFinal || variableMirror.isConst;

  @override
  getValue({required instance}) {
    _checkIsNullAndStatic(instance);

    if (isStatic) {
      return ReflectorStandardUtilities.getStaticInstance(reflect: reflectable, type: classMirror.dynamicReflectedType).invokeGetter(name);
    } else {
      return ReflectorStandardUtilities.getInstance(reflect: reflectable, object: instance).invokeGetter(name);
    }
  }

  @override
  void setValue({required instance, required newValue, bool beforeVerifying = true}) {
    _checkIsNullAndStatic(instance);

    final formatedValue = reflectedType.convertObject(newValue);

    if (beforeVerifying) {
      verifyValueDirectly(value: newValue, parentEntity: instance);
    }

    if (isStatic) {
      ReflectorStandardUtilities.getStaticInstance(reflect: reflectable, type: classMirror.dynamicReflectedType).invokeSetter(name, formatedValue);
    } else {
      ReflectorStandardUtilities.getInstance(reflect: reflectable, object: instance).invokeSetter(name, formatedValue);
    }
  }

  void _checkIsNullAndStatic(instance) {
    if (instance == null && !isStatic) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: trc('The field %1 is not static, a variable is required to get or set its value', [formalName]),
      );
    }
  }

  @override
  String toString() => 'Field $name ($reflectedType)';
}
