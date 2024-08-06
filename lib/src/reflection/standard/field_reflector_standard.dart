import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/interfaces/ifield_reflection.dart';
import 'package:maxi_library/src/reflection/interfaces/ireflection_type.dart';
import 'package:maxi_library/src/reflection/standard/reflector_standard_utilities.dart';
import 'package:reflectable/reflectable.dart';

class FieldReflectorStandard with IFieldReflection {
  final Reflectable reflectable;
  final ClassMirror classMirror;
  final VariableMirror variableMirror;

  @override
  late final IReflectionType fieldType;

  FieldReflectorStandard({required this.reflectable, required this.classMirror, required this.variableMirror}) {
    fieldType = ReflectionManager.getReflectionType(variableMirror.dynamicReflectedType);
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
  void setValue({required instance, required newValue}) {
    _checkIsNullAndStatic(instance);

    final formatedValue = fieldType.convertObject(newValue);
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
        message: trc('The field %1 is not static, a variable is required to get or set its value', [name]),
      );
    }
  }
}
