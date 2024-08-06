import 'package:maxi_library/maxi_library.dart';

enum PrimitiesType { isInt, isDouble, isNum, isString, isBoolean, isDateTime }

mixin ReflectionUtilities {
  static PrimitiesType? isPrimitive(Type type) {
    return switch (type) {
      const (String) => PrimitiesType.isString,
      const (int) => PrimitiesType.isInt,
      const (double) => PrimitiesType.isDouble,
      const (bool) => PrimitiesType.isBoolean,
      const (DateTime) => PrimitiesType.isDateTime,
      const (num) => PrimitiesType.isNum,
      _ => null,
    };
  }

  static dynamic primitiveClone(dynamic item) {
    if (item is Enum) {
      return primitiveClone(item.index);
    }

    return switch (item.runtimeType) {
      const (String) => item.toString(),
      const (int) => (item as int) * 1,
      const (double) => (item as double) * 1,
      const (bool) => (item as bool) ? true : false,
      const (num) => (item as num) * 1,
      const (DateTime) => DateTime(
          (item as DateTime).year,
          item.month,
          item.day,
          item.hour,
          item.minute,
          item.second,
          item.millisecond,
          item.microsecond,
        ),
      _ => throw NegativeResult(identifier: NegativeResultCodes.wrongType, message: 'The value is not a primitive value type ("${item.runtimeType}")')
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
    };
  }

  static dynamic convertSpecificPrimitive({required PrimitiesType type, required dynamic value}) {
    cautious(reasonFailure: () => tr('Null values are not accepted'), function: value!);
    return switch (type) {
      PrimitiesType.isInt => ConverterUtilities.toInt(value: value),
      PrimitiesType.isDouble => ConverterUtilities.toDouble(value: value),
      PrimitiesType.isNum => ConverterUtilities.toDouble(value: value),
      PrimitiesType.isString => value.toString(),
      PrimitiesType.isBoolean => ConverterUtilities.toBoolean(value: value),
      PrimitiesType.isDateTime => ConverterUtilities.toDateTime(value: value),
    };
  }
}
