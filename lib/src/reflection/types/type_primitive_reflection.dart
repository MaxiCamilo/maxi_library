import 'package:maxi_library/maxi_library.dart';

class TypePrimitiveReflection with IReflectionType {
  @override
  final List annotations;

  @override
  final Type type;

  late final PrimitiesType primitiveType;

  @override
  String get name => type.toString();

  TypePrimitiveReflection({required this.annotations, required this.type}) {
    primitiveType = volatile(detail:  tr('The type %1 is not primitive', [type]), function: () => ReflectionUtilities.isPrimitive(type)!);
  }

  @override
  cloneObject(originalItem) {
    return ReflectionUtilities.primitiveClone(originalItem);
  }

  @override
  convertObject(originalItem) {
    if (originalItem.runtimeType == type) {
      return cloneObject(originalItem);
    } else {
      return ReflectionUtilities.convertSpecificPrimitive(type: primitiveType, value: originalItem);
    }
  }

  @override
  generateEmptryObject() {
    return ReflectionUtilities.generateDefaultPrimitive(primitiveType);
  }

  @override
  bool isCompatible(item) {
    return item.runtimeType == type;
  }

  @override
  bool isTypeCompatible(Type type) {
    return ReflectionUtilities.isPrimitive(type) != null;
  }

  @override
  serializeToMap(item) {
    if (item is DateTime) {
      return item.millisecondsSinceEpoch;
    }
    return ReflectionUtilities.primitiveClone(item);
  }

  @override
  String toString() => 'Primitive type ($primitiveType)';
}
