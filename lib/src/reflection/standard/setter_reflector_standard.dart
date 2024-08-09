import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/interfaces/isetter_reflector.dart';
import 'package:maxi_library/src/reflection/standard/reflector_standard_utilities.dart';
import 'package:reflectable/reflectable.dart';

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

  SetterReflectorStandard({required this.reflectable, required this.classMirror, required this.methodMirror}) {
    reflectedType = ReflectionManager.getReflectionType(methodMirror.parameters.first.dynamicReflectedType, annotations: methodMirror.metadata);
    if (methodMirror.simpleName.last == '=') {
      name = methodMirror.simpleName.replaceAll('=', '');
    } else {
      name = methodMirror.simpleName;
    }

    formalName = FormalName.searchFormalName(realName: name, annotations: annotations);
    validators = methodMirror.metadata.whereType<ValueValidator>().toList();
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
}
