import 'package:maxi_library/maxi_library.dart';

class TypePrimitiveReflection with IReflectionType, IValueGenerator, IPrimitiveValueGenerator {
  @override
  final List annotations;

  @override
  final Type type;

  @override
  late final PrimitiesType primitiveType;

  @override
  String get name => type.toString();

  @override
  Oration get description => Description.searchDescription(annotations: annotations);

  TypePrimitiveReflection({required this.annotations, required this.type}) {
    primitiveType = volatile(detail: Oration(message: 'The type %1 is not primitive', textParts: [type]), function: () => ConverterUtilities.isPrimitive(type)!);
  }

  @override
  cloneObject(originalItem) {
    return ConverterUtilities.primitiveClone(originalItem);
  }

  @override
  convertObject(originalItem) {
    if (originalItem.runtimeType == type) {
      return cloneObject(originalItem);
    } else {
      return ConverterUtilities.convertSpecificPrimitive(type: primitiveType, value: originalItem);
    }
  }

  @override
  generateEmptryObject() {
    return ConverterUtilities.generateDefaultPrimitive(primitiveType);
  }

  @override
  bool isCompatible(item) {
    return item.runtimeType == type;
  }

  @override
  bool isTypeCompatible(Type type) {
    return ConverterUtilities.isPrimitive(type) != null;
  }

  @override
  serializeToMap(item) {
    if (item is DateTime) {
      return item.toUtc().millisecondsSinceEpoch;
    }
    return ConverterUtilities.primitiveClone(item);
  }

  @override
  String toString() => 'Primitive type ($primitiveType)';

  @override
  convertToPrimitiveValue(value) {
    serializeToMap(value);
  }

  @override
  interpretPrimitiveValue(value) {
    convertObject(value);
  }
}
