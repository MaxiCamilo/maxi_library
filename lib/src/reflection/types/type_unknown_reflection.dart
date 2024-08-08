import 'package:maxi_library/maxi_library.dart';


class TypeUnknownReflection with IReflectionType {
  @override
  List get annotations => const [];

  @override
  final Type type;

  @override
  String get name => type.toString();

  const TypeUnknownReflection({required this.type});

  @override
  cloneObject(originalItem) {
    throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: trc('The object of type %1 cannot be cloned, because it is an unreflected or unknown type', [type]));
  }

  @override
  convertObject(originalItem) {
    throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: trc('The object of type %1 cannot be converted, because it is an unreflected or unknown type', [type]));
  }

  @override
  generateEmptryObject() {
    throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: trc('Unable to create an instance of type %1, because it is an unreflected or unknown type', [type]));
  }

  @override
  bool isCompatible(item) {
    return item.runtimeType == type;
  }

  @override
  bool isTypeCompatible(Type type) {
    return this.type == type;
  }

  @override
  serializeToMap(item) {
    throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: trc('It is not safe to assign an object of type %1, as it is an unknown and unreflected type', [type]));
  }

  @override
  String toString() => 'Unknown type';
}
