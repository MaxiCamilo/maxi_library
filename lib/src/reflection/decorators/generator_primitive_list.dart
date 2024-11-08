import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';

class GeneratorPrimitiveList<T> with IValueGenerator, IReflectionType, IPrimitiveValueGenerator {
  @override
  List get annotations => [];

  @override
  Type get type => List<T>;

  @override
  String get name => 'Primitive List $T';

  @override
  PrimitiesType get primitiveType => PrimitiesType.isString;

  @override
  TranslatableText get description => Description.searchDescription(annotations: annotations);

  const GeneratorPrimitiveList();

  @override
  cloneObject(originalItem) {
    if (originalItem is Iterable) {
      final newList = <T>[];
      for (final item in originalItem) {
        final reflector = volatile(detail: tr('Item at list is primitive', [item.runtimeType]), function: () => ReflectionUtilities.isPrimitive(item.runtimeType)!);
        newList.add(ReflectionUtilities.convertSpecificPrimitive(type: reflector, value: item));
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
    if (originalItem is Iterable) {
      return cloneObject(originalItem);
    } else if (originalItem is String && originalItem.isNotEmpty && originalItem.first == '[' && originalItem.last == ']') {
      final jsonValue = volatile(detail: tr('Text value is a json list'), function: () => json.decode(originalItem) as List);
      return cloneObject(jsonValue);
    } else if (originalItem is T) {
      return <T>[originalItem];
    }

    throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: tr('Cannot cast type %1 to a primitive list'));
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

  @override
  convertToPrimitiveValue(value) {
    final reflector = TypePrimitiveReflection(annotations: annotations, type: T);
    if (value is Iterable) {
      final buffer = StringBuffer('[');

      buffer.write(value.map((x) {
        return json.encode('${reflector.serializeToMap(x)}');
      }).join(','));

      buffer.write(']');
      return buffer.toString();
    } else {
      return json.encode('[${reflector.serializeToMap(value)}]');
    }
  }

  @override
  interpretPrimitiveValue(value) {
    final reflector = TypePrimitiveReflection(annotations: annotations, type: T);
    if (value is Iterable) {
      final list = <T>[];

      for (final item in value) {
        list.add(reflector.convertObject(item));
      }

      return list;
    } else {
      return <T>[reflector.convertObject(reflector)];
    }
  }
}
