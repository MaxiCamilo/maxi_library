import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/interfaces/isetter_reflector.dart';
import 'package:maxi_library/src/reflection/old_implementation/reflector_standard_utilities.dart';

class SetterReflectorStandard with IDeclarationReflector, ISetterReflector {
  final Reflectable reflectable;
  final ClassMirror classMirror;
  final MethodMirror methodMirror;

  @override
  late final IReflectionType reflectedType;

  @override
  late final String name;

  @override
  late final String formalName;

  @override
  late final List<ValueValidator> validators;

  late final CustomInterpretation? customInterpretation;

  SetterReflectorStandard({required this.reflectable, required this.classMirror, required this.methodMirror}) {
    reflectedType = ReflectionManager.getReflectionType(methodMirror.parameters.first.dynamicReflectedType, annotations: methodMirror.metadata);
    if (methodMirror.simpleName.last == '=') {
      name = methodMirror.simpleName.replaceAll('=', '');
    } else {
      name = methodMirror.simpleName;
    }

    formalName = FormalName.searchFormalName(realName: name, annotations: annotations);
    validators = methodMirror.metadata.whereType<ValueValidator>().toList();

    customInterpretation = methodMirror.metadata.selectByType<CustomInterpretation>();
  }

  @override
  List get annotations => methodMirror.metadata;

  @override
  bool get isStatic => methodMirror.isStatic;

  @override
  void setValue({required instance, required newValue, bool beforeVerifying = true}) {
    if (instance == null && !isStatic) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: trc('The method %1 is not static, it requires an instance', [formalName]),
      );
    }

    if (customInterpretation != null) {
      newValue = customInterpretation!.performInterpretation(value: newValue, declaration: this);
    } else {
      newValue = reflectedType.convertObject(newValue);
    }

    if (beforeVerifying) {
      verifyValueDirectly(value: newValue, parentEntity: instance);
    }

    if (isStatic) {
      ReflectorStandardUtilities.getStaticInstance(reflect: reflectable, type: classMirror.dynamicReflectedType).invokeSetter(name, newValue);
    } else {
      ReflectorStandardUtilities.getInstance(reflect: reflectable, object: instance).invokeSetter(name, newValue);
    }
  }
}
