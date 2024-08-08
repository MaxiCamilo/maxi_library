import 'package:maxi_library/maxi_library.dart';

class TypeVoidReflection with IReflectionType {
  const TypeVoidReflection();

  @override
  List get annotations => [];

  @override
  cloneObject(originalItem) {
    return null;
  }

  @override
  convertObject(originalItem) {
    return null;
  }

  @override
  generateEmptryObject() {
    return null;
  }

  @override
  bool isCompatible(item) {
    return false;
  }

  @override
  bool isTypeCompatible(Type type) {
    return false;
  }

  @override
  String get name => 'void';

  @override
  serializeToMap(item) {
    throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: trc('It is not safe to assign an object of type %1, as it is an void type', [type]));
  }

  @override
  Type get type => dynamic;

  @override
  String toString() => 'void type';
}
