import 'dart:convert';
import 'dart:typed_data';

import 'package:maxi_library/maxi_library.dart';

enum PrimitiesType { isInt, isDouble, isNum, isString, isBoolean, isDateTime, isBinary }

mixin ReflectionUtilities {
  static PrimitiesType? isPrimitive(Type type) {
    return switch (type) {
      const (String) => PrimitiesType.isString,
      const (int) => PrimitiesType.isInt,
      const (double) => PrimitiesType.isDouble,
      const (bool) => PrimitiesType.isBoolean,
      const (DateTime) => PrimitiesType.isDateTime,
      const (num) => PrimitiesType.isNum,
      const (Uint8List) || const (List<int>) => PrimitiesType.isBinary,
      _ => null,
    };
  }

  static String serializeToJson(dynamic value) {
    if (value is Enum) {
      return value.index.toString();
    }

    final type = volatile(detail: Oration(message: '%1 is primitive', textParts: [value.runtimeType]), function: () => isPrimitive(value.runtimeType)!);
    return switch (type) {
      PrimitiesType.isInt => value.toString(),
      PrimitiesType.isDouble => value.toString(),
      PrimitiesType.isNum => value.toString(),
      PrimitiesType.isString => '"${value.toString()}"',
      PrimitiesType.isBoolean => value.toString(),
      PrimitiesType.isDateTime => (value as DateTime).millisecondsSinceEpoch.toString(),
      PrimitiesType.isBinary => '"${utf8.decode(value)}"',
    };
  }

  static dynamic primitiveClone(dynamic item) {
    if (item is Enum) {
      return primitiveClone(item.index);
    }

    return switch (item.runtimeType) {
      const (String) => '$item',
      const (int) => (item as int) * 1,
      const (double) => (item as double) * 1,
      const (bool) => (item as bool) ? true : false,
      const (num) => (item as num) * 1,
      const (DateTime) => (item as DateTime).add(Duration(milliseconds: 0)),
      const (Uint8List) || const (List<int>) => Uint8List.fromList((item as List<int>)),
      _ => throw NegativeResult(identifier: NegativeResultCodes.wrongType, message: Oration(message: 'The value is not a primitive value type ("%1")', textParts: [item.runtimeType]))
    };
  }

  static dynamic generateDefaultPrimitive(PrimitiesType type) {
    return switch (type) {
      PrimitiesType.isInt => 0,
      PrimitiesType.isDouble => 0.0,
      PrimitiesType.isNum => 0,
      PrimitiesType.isString => '',
      PrimitiesType.isBoolean => false,
      PrimitiesType.isDateTime => DateTime.now(),
      PrimitiesType.isBinary => Uint8List.fromList([]),
    };
  }

  static dynamic convertSpecificPrimitive({required PrimitiesType type, required dynamic value}) {
    cautious(reasonFailure: Oration(message: 'Null values are not accepted'), function: () => value!);
    return switch (type) {
      PrimitiesType.isInt => ConverterUtilities.toInt(value: value),
      PrimitiesType.isDouble => ConverterUtilities.toDouble(value: value),
      PrimitiesType.isNum => ConverterUtilities.toDouble(value: value),
      PrimitiesType.isString => value.toString(),
      PrimitiesType.isBoolean => ConverterUtilities.toBoolean(value: value),
      PrimitiesType.isDateTime => ConverterUtilities.toDateTime(value: value),
      PrimitiesType.isBinary => ConverterUtilities.toBinary(value: value),
    };
  }
}
