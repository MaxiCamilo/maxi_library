import 'package:maxi_library/maxi_library.dart';

class GeneratorPrimitiveList<T> with IValueGenerator, IReflectionType {
  @override
  List get annotations => [];

  @override
  Type get type => List<T>;

  @override
  String get name => 'Primitive List $T';

  const GeneratorPrimitiveList();

  @override
  cloneObject(originalItem) {
    if (originalItem is Iterable) {
      final newList = <T>[];
      for (final item in originalItem) {
        final reflector = volatile(detail: tr('Item at list is primitive',[item.runtimeType]), function: ()=> ReflectionUtilities.isPrimitive(item.runtimeType)!);
        newList.add(ReflectionUtilities.convertSpecificPrimitive(type: reflector ,value: item));
      }
      return newList;
    } else if (originalItem is T) {
      return [ReflectionUtilities.primitiveClone(originalItem)];
    } else {
      return [ReflectionUtilities.convertSpecificPrimitive(type: ReflectionUtilities.isPrimitive(originalItem.runtimeType)!, value: originalItem)];
    }
  }

  @override
  convertObject(originalItem) {
    return cloneObject(originalItem);
  }

  @override
  generateEmptryObject() {
    return <T>[];
  }

  @override
  bool isCompatible(item) {
    return item is Iterable<T> || item is T;
  }

  @override
  bool isTypeCompatible(Type type) {
    return type == T || type == List<T>;
  }

  @override
  serializeToMap(item) {
    return cloneObject(item);
  }
}
