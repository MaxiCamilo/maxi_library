import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';

class TypeDynamicReflection with IReflectionType {
  const TypeDynamicReflection();

  @override
  List get annotations => [];

  @override
  String get name => 'dynamic';

  @override
  Oration get description => Oration.empty;

  @override
  Type get type => dynamic;

  @override
  cloneObject(originalItem) {
    return convertObject(originalItem);
  }

  @override
  convertObject(originalItem) {
    if (originalItem == null) {
      return originalItem;
    }

    if (ConverterUtilities.isPrimitive(originalItem.runtimeType) != null) {
      return ConverterUtilities.primitiveClone(originalItem);
    }

    final reflectedClass = ReflectionManager.getReflectionType(originalItem.runtimeType, annotations: []);
    if (reflectedClass is! TypeUnknownReflection && reflectedClass is! TypeDynamicReflection) {
      return reflectedClass.convertObject(originalItem);
    }

    return originalItem;
  }

  @override
  generateEmptryObject() {
    return null;
  }

  @override
  bool isCompatible(item) {
    return true;
  }

  @override
  bool isTypeCompatible(Type type) {
    return true;
  }

  @override
  serializeToMap(item) {
    if (item == null) {
      log('Warning!: There is a null object in a dynamic property. It was changed to an empty string');
      return '';
    }

    final reflectedClass = ReflectionManager.getReflectionType(item.runtimeType, annotations: []);
    if (reflectedClass is! TypeUnknownReflection && reflectedClass is! TypeDynamicReflection) {
      return reflectedClass.serializeToMap(item);
    }

    log('Warning!: There is a type of unkonwn objet to the a map');
    return item;
  }

  @override
  String toString() => 'Dynamic type';
}
