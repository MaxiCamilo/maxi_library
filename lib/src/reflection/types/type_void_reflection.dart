import 'package:maxi_library/maxi_library.dart';

class TypeVoidReflection with IReflectionType {
  const TypeVoidReflection();

  @override
  List get annotations => [];

  @override
  Oration get description => Oration(message: 'Hello darkness my old friend');

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
    throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: Oration(message: 'It is not safe to assign an object of type %1, as it is an void type', textParts: [type]));
  }

  @override
  Type get type => dynamic;

  @override
  String toString() => 'void type';
}
