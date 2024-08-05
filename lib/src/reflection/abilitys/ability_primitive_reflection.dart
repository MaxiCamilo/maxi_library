import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/interfaces/ireflection_type.dart';

mixin AbilityPrimitiveReflection on IReflectionType {
  PrimitiesType get primitiveType;

  @override
  cloneObject(originalItem) {
    return ReflectionUtilities.primitiveClone(originalItem);
  }

  @override
  convertObject(originalItem) {
    return ReflectionUtilities.primitiveClone(originalItem);
  }

  @override
  generateEmptryObject() {
    return ReflectionUtilities.generateDefaultPrimitive(primitiveType);
  }

  @override
  bool isCompatible(item) {
    // TODO: implement isCompatible
    throw UnimplementedError();
  }

  @override
  bool isTypeCompatible(Type type) {
    // TODO: implement isTypeCompatible
    throw UnimplementedError();
  }

  @override
  serializeToMap(item) {
    // TODO: implement serializeToMap
    throw UnimplementedError();
  }
}
