import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/interfaces/igetter_reflector.dart';
import 'package:maxi_library/src/reflection/standard/reflector_standard_utilities.dart';

class GetterReflectorStandard with IDeclarationReflector, IGetterReflector {
  final Reflectable reflectable;
  final ClassMirror classMirror;
  final MethodMirror methodMirror;

  @override
  late final IReflectionType reflectedType;

  late final CustomSerialization? customSerialization;

  GetterReflectorStandard({required this.reflectable, required this.classMirror, required this.methodMirror}) {
    reflectedType = ReflectionManager.getReflectionType(methodMirror.reflectedReturnType, annotations: methodMirror.metadata);
    formalName = FormalName.searchFormalName(realName: name, annotations: annotations);
    validators = methodMirror.metadata.whereType<ValueValidator>().toList();

    customSerialization = methodMirror.metadata.selectByType<CustomSerialization>();
  }

  @override
  List get annotations => methodMirror.metadata;

  @override
  bool get isStatic => methodMirror.isStatic;

  @override
  String get name => methodMirror.simpleName;

  @override
  late final String formalName;

  @override
  late final List<ValueValidator> validators;

  @override
  getValue({required instance}) {
    if (instance == null && !isStatic) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: trc('The method %1 is not static, it requires an instance', [formalName]),
      );
    }

    late final dynamic value;

    if (isStatic) {
      value = ReflectorStandardUtilities.getStaticInstance(reflect: reflectable, type: classMirror.dynamicReflectedType).invokeGetter(name);
    } else {
      value = ReflectorStandardUtilities.getInstance(reflect: reflectable, object: instance).invokeGetter(name);
    }

    if (customSerialization != null) {
      return customSerialization!.performSerialization(entity: value, declaration: this);
    } else {
      return value;
    }
  }
}
