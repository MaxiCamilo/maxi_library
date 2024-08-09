import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/decorators/formal_name.dart';
import 'package:maxi_library/src/reflection/interfaces/ideclaration_reflector.dart';
import 'package:maxi_library/src/reflection/interfaces/igetter_reflector.dart';
import 'package:maxi_library/src/reflection/standard/reflector_standard_utilities.dart';
import 'package:reflectable/reflectable.dart';

class GetterReflectorStandard with IDeclarationReflector, IGetterReflector {
  final Reflectable reflectable;
  final ClassMirror classMirror;
  final MethodMirror methodMirror;

  @override
  late final IReflectionType reflectedType;

  GetterReflectorStandard({required this.reflectable, required this.classMirror, required this.methodMirror}) {
    reflectedType = ReflectionManager.getReflectionType(methodMirror.reflectedReturnType, annotations: methodMirror.metadata);
    formalName = FormalName.searchFormalName(realName: name, annotations: annotations);
    validators = methodMirror.metadata.whereType<ValueValidator>().toList();
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

    if (isStatic) {
      return ReflectorStandardUtilities.getStaticInstance(reflect: reflectable, type: classMirror.dynamicReflectedType).invokeGetter(name);
    } else {
      return ReflectorStandardUtilities.getInstance(reflect: reflectable, object: instance).invokeGetter(name);
    }
  }
}
