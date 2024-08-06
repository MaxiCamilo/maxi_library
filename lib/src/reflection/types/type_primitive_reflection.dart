import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/interfaces/ireflection_type.dart';

class TypePrimitiveReflection with IReflectionType {
  @override
  final List annotations;

  @override
  final Type type;
  
  late final PrimitiesType primitiveType;

  @override
  String get name => type.toString();

  TypePrimitiveReflection({required this.annotations, required this.type}) {
    primitiveType = volatile(detail: () => trc('The type %1 is not primitive', [type]), function: () => ReflectionUtilities.isPrimitive(type)!);
  }

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
    return ReflectionUtilities.isPrimitive(item.runtimeType) != null;
  }

  @override
  bool isTypeCompatible(Type type) {
    return ReflectionUtilities.isPrimitive(type) != null;
  }

  @override
  serializeToMap(item) {
    return ReflectionUtilities.primitiveClone(item);
  }
}
