import 'dart:convert';
import 'dart:typed_data';

import 'package:maxi_library/maxi_library.dart';

enum PrimitiesType { isInt, isDouble, isNum, isString, isBoolean, isDateTime, isBinary, isObjectMap }

mixin ConverterUtilities {
  static int toInt({required dynamic value, Oration propertyName = Oration.empty, bool ifEmptyIsZero = false}) {
    if (value == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nullValue,
        message: Oration(message: 'The value is null'),
      );
    } else if (value is int) {
      return value;
    } else if (value is double) {
      return value.toInt();
    } else if (value is String) {
      if (ifEmptyIsZero && value.isEmpty) {
        return 0;
      }
      return volatileFactory(
        function: () => int.parse(value),
        errorFactory: (x) => NegativeResult(
            identifier: NegativeResultCodes.incorrectFormat, message: Oration(message: 'The property %1 must be an integer number, but non-numeric values ​​were found in the text', textParts: [propertyName]), cause: x),
      );
    } else if (value is bool) {
      return value ? 1 : 0;
    } else if (value is DateTime) {
      return value.isUtc ? value.millisecondsSinceEpoch : value.toUtc().millisecondsSinceEpoch;
    } else if (value is Enum) {
      return value.index;
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.incorrectFormat,
        message:
            propertyName.isNotEmpty ? Oration(message: 'The property %1 has an unknown value, an integer number is expected', textParts: [propertyName]) : Oration(message: 'Cannot transform value to integer number'),
      );
    }
  }

  static double toDouble({required dynamic value, Oration propertyName = Oration.empty, bool ifEmptyIsZero = false}) {
    if (value == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nullValue,
        message: Oration(message: 'The value is null'),
      );
    } else if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      if (ifEmptyIsZero && value.isEmpty) {
        return 0;
      }
      return volatileFactory(
        function: () => double.parse(value),
        errorFactory: (x) => NegativeResult(
          identifier: NegativeResultCodes.incorrectFormat,
          message: Oration(message: 'The property %1 must be an decimal number, but non-numeric values ​​were found in the text', textParts: [propertyName]),
          cause: x,
        ),
      );
    } else if (value is bool) {
      return value ? 1 : 0;
    } else if (value is DateTime) {
      return value.isUtc ? value.millisecondsSinceEpoch.toDouble() : value.toUtc().millisecondsSinceEpoch.toDouble();
    } else if (value is Enum) {
      return value.index.toDouble();
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.incorrectFormat,
        message: propertyName.isNotEmpty ? Oration(message: 'The property %1 has an unknown value, an double number is expected', textParts: [propertyName]) : Oration(message: 'Cannot transform value to integer number'),
      );
    }
  }

  static bool toBoolean({required dynamic value, Oration propertyName = Oration.empty}) {
    if (value == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nullValue,
        message: Oration(message: 'A null value cannot be interpreted as a boolean in the property ', textParts: [propertyName]),
      );
    } else if (value is bool) {
      return value;
    } else if (value is num) {
      return value == 1;
    } else if (value is String) {
      final texto = value.toLowerCase();
      return switch (texto) {
        'true' => true,
        'false' => false,
        'si' => true,
        'no' => false,
        'yes' => true,
        't' => true,
        'f' => false,
        's' => true,
        'y' => true,
        'n' => false,
        '0' => false,
        '1' => true,
        _ => throw NegativeResult(
            identifier: NegativeResultCodes.incorrectFormat,
            message: Oration(message: 'The property %1 does not have a valid text to be transformed into a boolean option', textParts: [propertyName]),
          )
      };
    } else {
      throw NegativeResult(identifier: NegativeResultCodes.wrongType, message: Oration(message: 'The property %1 only accepts boolean values ​​or equivalent', textParts: [propertyName]));
    }
  }

  static String toNormaliceString(dynamic value) {
    if (value is DateTime) {
      return value.isUtc ? value.toIso8601String() : value.toUtc().toIso8601String();
    }

    return value == null ? '' : value.toString();
  }

  static Enum toEnum({
    required List<Enum> optionsList,
    required dynamic value,
    Oration propertyName = Oration.empty,
  }) {
    if (value is String) {
      final isActuallyInt = int.tryParse(value);
      if (isActuallyInt != null) {
        return toEnum(value: isActuallyInt, optionsList: optionsList, propertyName: propertyName);
      }

      final letra = value.toLowerCase();
      for (final item in optionsList) {
        if (item.name.toLowerCase() == letra) {
          return item;
        }
      }
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidValue,
        message:
            propertyName.isNotEmpty ? Oration(message: 'The property %1 does not have the "%2" option', textParts: [propertyName, value]) : Oration(message: 'Value does not have the "%1" option', textParts: [value]),
      );
    } else if (value is num) {
      for (final item in optionsList) {
        if (item.index == value) {
          return item;
        }
      }
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidValue,
        message:
            propertyName.isNotEmpty ? Oration(message: 'The property %1 does not have the N° %2 option', textParts: [propertyName, value]) : Oration(message: 'Value does not have the N° %1 option', textParts: [value]),
      );
    } else if (value is Enum) {
      if (optionsList.any((element) => value == element)) {
        return value;
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.wrongType,
          message: propertyName.isNotEmpty
              ? Oration(message: 'The property %1 only accepts the type "Enum", not thing "%2" option', textParts: [propertyName, value])
              : Oration(message: 'Value does not have the N° "%1" option', textParts: [value]),
        );
      }
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: propertyName.isNotEmpty
            ? Oration(message: 'The property %1 only accepts the type enumerator, not %2', textParts: [propertyName, value.runtimeType])
            : Oration(message: 'The value only accepts the type enumerator, not "%1"', textParts: [value.runtimeType]),
      );
    }
  }

  static DateTime toDateTime({
    required dynamic value,
    bool isLocal = true,
    Oration propertyName = Oration.empty,
  }) {
    if (value == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nullValue,
        message: Oration(message: 'A null value cannot be interpreted as a boolean in the property %1', textParts: [propertyName]),
      );
    } else if (value is DateTime) {
      if (value.isUtc && isLocal) {
        return value.toLocal();
      } else if (!value.isUtc && !isLocal) {
        return value.toUtc();
      }
      return value;
    } else if (value is num) {
      return volatile(
        detail: Oration(message: 'The property %1 does not have a valid number to be adapted to date', textParts: [propertyName]),
        function: () {
          final datetime = DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
          if (isLocal) {
            return datetime.toLocal();
          } else {
            return datetime;
          }
        },
      );
    } else if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (ex) {
        throw NegativeResult(
          identifier: NegativeResultCodes.invalidValue,
          message: propertyName.isNotEmpty
              ? Oration(message: 'The property %1 does not have a valid textuan format to be adapted to date', textParts: [propertyName])
              : Oration(message: 'The value does not have a valid textan format to be adapted to date'),
        );
      }
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: propertyName.isNotEmpty
            ? Oration(message: 'The property %1 only accepts the type date or equivalent, not %2', textParts: [propertyName, value.runtimeType])
            : Oration(message: 'The value only accepts the type date or equivalent, not %1', textParts: [value.runtimeType]),
      );
    }
  }

  static Uint8List toBinary({required dynamic value, Oration propertyName = Oration.empty, Encoding encoder = utf8}) {
    if (value is Uint8List) {
      return value;
    } else if (value is List<int>) {
      return Uint8List.fromList(value);
    } else if (value is String) {
      return Uint8List.fromList(volatile(
        detail: propertyName.isNotEmpty ? Oration(message: 'Encoding property %1 with %2', textParts: [propertyName, encoder.name]) : Oration(message: 'Encoding value with %1', textParts: [encoder.name]),
        function: () => encoder.encode(value),
      ));
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: propertyName.isNotEmpty
            ? Oration(message: 'The property %1 only accepts the type binary or equivalent, not %2', textParts: [propertyName, value.runtimeType])
            : Oration(message: 'The value only accepts the type binary or equivalent, not %1', textParts: [value.runtimeType]),
      );
    }
  }

  static dynamic normalizePrimitive({required dynamic value, Encoding binaryEncoder = utf8}) {
    if (value == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nullValue,
        message: Oration(message: 'A null value cannot be interpreted as a primitive value'),
      );
    }

    switch (value) {
      case int _:
      case double _:
      case bool _:
      case String _:
        return value;
      case DateTime dt:
        return dt.millisecondsSinceEpoch;
      case Enum e:
        return e.index;
      case List lista:
        return json.encode(lista.map((e) => normalizePrimitive(value: e, binaryEncoder: binaryEncoder)));
      case Map<String, dynamic> mapa:
        return json.encode(mapa);
      default:
        throw NegativeResult(
          identifier: NegativeResultCodes.implementationFailure,
          message: Oration(message: '[normalizePrimitive] The value is not a primitive type'),
        );
    }
  }

  //static String trySerializeToJson(dynamic item) => json.encode(trySerializeToPrimitive(item));

  static dynamic serializeToJson(dynamic item) {
    if (item is Map<String, dynamic>) {
      return json.encode(item.map((key, value) {
        final primitiveType = isPrimitive(value.runtimeType);
        if (primitiveType != null) {
          return MapEntry(key, primitiveClone(value));
        } else {
          return MapEntry(key, serializeToJson(value));
        }
      }));
    }

    if (item is List) {
      return json.encode(item.map((value) {
        final primitiveType = isPrimitive(value.runtimeType);
        if (primitiveType != null) {
          return convertSpecificPrimitive(type: primitiveType, value: value);
        } else {
          return serializeToJson(value);
        }
      }).toList(growable: false));
    }

    final primitiveType = isPrimitive(item.runtimeType);
    if (primitiveType != null) {
      //throw NegativeResult(identifier: NegativeResultCodes.invalidValue, message: const Oration(message: 'A primitive cannot be directly serialized to JSON'));
      return ConverterUtilities.convertSpecificPrimitive(type: primitiveType, value: item);
    }

    if (item is ICustomSerialization) {
      final result = item.serialize();
      if (result is String) {
        return result;
      } else {
        return serializeToJson(result);
      }
    }

    return ReflectionManager.serialzeEntityToJson(value: item);
  }

  static T castJson<T>({required String text}) => castDynamicJson(text: text, type: T) as T;

  static dynamic castDynamicJson({required String text, required Type type}) {
    if (type.toString() == 'void') {
      return null;
    }

    if (type == dynamic) {
      return tryCastDynamicJson(text: text) ?? text;
    }

    final primitiveType = isPrimitive(type);
    if (primitiveType != null) {
      return convertSpecificPrimitive(type: primitiveType, value: text);
    }

    if (type == Map<String, dynamic>) {
      return interpretToObjectJson(text: text);
    }

    if (type == List<Map<String, dynamic>>) {
      return interpretToObjectListJson(text: text);
    }

    if (type == Oration) {
      return Oration.interpretFromJson(text: text);
    }

    if (type == NegativeResult) {
      return NegativeResult.interpretJson(jsonText: text);
    }

    if (type == InvocationParameters) {
      return InvocationParameters.interpretFromJson(text);
    }

    return ReflectionManager.interpretJson(rawText: text, tryToCorrectNames: false);
  }

  static dynamic tryCastDynamicJson({required String text}) {
    final mapJson = interpretJson(text: text);
    if (mapJson is! Map<String, dynamic>) {
      return null;
    }

    final type = mapJson.getRequiredValueWithSpecificType<String>('\$type');

    if (type == 'Oration') {
      return Oration.interpret(map: mapJson);
    } else if (type.startsWith('error')) {
      return NegativeResultValue.interpret(values: mapJson, checkTypeFlag: true);
    } else if (type == 'Parameters') {
      return InvocationParameters.interpret(mapJson);
    }

    final reflector = ReflectionManager.getReflectionEntityByName(type);
    return reflector.interpret(value: mapJson, tryToCorrectNames: true);
  }

  static dynamic interpretJson({required String text, Oration? extra}) {
    return volatile(
      detail: extra == null ? Oration(message: 'The content is not valid json') : Oration(message: 'The content is not valid json %1', textParts: [extra]),
      function: () => json.decode(text),
    );
  }

  static Map<String, dynamic> interpretToObjectJson({required String text, Oration? extra}) {
    return volatile(
        detail: extra == null ? Oration(message: 'Expected a json object, but received a json listing or value') : Oration(message: 'Expected a json object, but received a json listing or value %1', textParts: [extra]),
        function: () => interpretJson(text: text, extra: extra) as Map<String, dynamic>);
  }

  static List interpretToJsonList({required String text, Oration? extra}) {
    return volatile(
        detail: extra == null
            ? Oration(message: 'Expected a json list, but received a json value or individual object')
            : Oration(message: 'Expected a json list, but received a json listing or value %1', textParts: [extra]),
        function: () => interpretJson(text: text, extra: extra) as List);
  }

  static List<int> interpretToJsonIntList({required String text, Oration? extra}) {
    return volatile(
        detail: extra == null
            ? Oration(message: 'A JSON list with identifiers was expected, but received a json value or individual object')
            : Oration(message: 'A JSON list with identifiers was expected, but received a json listing or value %1', textParts: [extra]),
        function: () => interpretJson(text: text, extra: extra) as List<int>);
  }

  static List<Map<String, dynamic>> interpretToObjectListJson({required String text, Oration? extra}) {
    return volatile(
        detail: extra == null
            ? Oration(message: 'Expected a list of json objects, but received a json list with an unknown value or a single value')
            : Oration(message: 'Expected a json object, but received a json listing or value %1', textParts: [extra]),
        function: () => (interpretJson(text: text, extra: extra) as List).cast<Map<String, dynamic>>()).toList();
  }

  // static String toJsonString(dynamic item) => volatile(detail: const Oration(message: 'The entered value cannot be converted to JSON text'), function: () => json.encode(item));

  static PrimitiesType? isPrimitive(Type type) {
    return switch (type) {
      const (String) => PrimitiesType.isString,
      const (int) => PrimitiesType.isInt,
      const (double) => PrimitiesType.isDouble,
      const (bool) => PrimitiesType.isBoolean,
      const (DateTime) => PrimitiesType.isDateTime,
      const (num) => PrimitiesType.isNum,
      const (Uint8List) || const (List<int>) => PrimitiesType.isBinary,
      const (Map<String, dynamic>) => PrimitiesType.isObjectMap,
      _ => null,
    };
  }

  static PrimitiesType? isPrimitiveByName(String typeName) {
    return switch (typeName) {
      const ('String') => PrimitiesType.isString,
      const ('int') => PrimitiesType.isInt,
      const ('double') => PrimitiesType.isDouble,
      const ('bool') => PrimitiesType.isBoolean,
      const ('DateTime') => PrimitiesType.isDateTime,
      const ('num') => PrimitiesType.isNum,
      const ('Uint8List') || const ('List<int>') => PrimitiesType.isBinary,
      const ('Map<String, dynamic>') => PrimitiesType.isObjectMap,
      _ => null,
    };
  }

  static String serializeToRawJson(dynamic value) {
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
      PrimitiesType.isObjectMap => json.encode(value),
    };
  }

  static dynamic serializeToPrimitive(dynamic value, {bool nullIsEmptryString = true}) {
    if (value == null) {
      if (nullIsEmptryString) {
        return '';
      } else {}
    }

    if (value is Enum) {
      return value.index.toString();
    }

    final primitive = isPrimitive(value.runtimeType);
    if (primitive != null) {
      return switch (primitive) {
        PrimitiesType.isInt => value,
        PrimitiesType.isDouble => value,
        PrimitiesType.isNum => value,
        PrimitiesType.isString => value,
        PrimitiesType.isBoolean => value,
        PrimitiesType.isDateTime => (value as DateTime).millisecondsSinceEpoch,
        PrimitiesType.isBinary => utf8.decode(value),
        PrimitiesType.isObjectMap => json.encode(value),
      };
    }

    return ConverterUtilities.serializeToJson(value);
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
      const (Map<String, dynamic>) => (item as Map<String, dynamic>).map((key, value) => MapEntry(key, primitiveClone(value))),
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
      PrimitiesType.isObjectMap => '{}',
    };
  }

  static dynamic convertSpecificPrimitive({required PrimitiesType type, required dynamic value}) {
    volatile(detail: Oration(message: 'Null values are not accepted'), function: () => value!);
    return switch (type) {
      PrimitiesType.isInt => ConverterUtilities.toInt(value: value),
      PrimitiesType.isDouble => ConverterUtilities.toDouble(value: value),
      PrimitiesType.isNum => ConverterUtilities.toDouble(value: value),
      PrimitiesType.isString => value.toString(),
      PrimitiesType.isBoolean => ConverterUtilities.toBoolean(value: value),
      PrimitiesType.isDateTime => ConverterUtilities.toDateTime(value: value),
      PrimitiesType.isBinary => ConverterUtilities.toBinary(value: value),
      PrimitiesType.isObjectMap => ConverterUtilities.serializeToJson(value),
    };
  }

  static List<String> parseCsvLine(String line) {
    final List<String> result = [];
    final StringBuffer buffer = StringBuffer();
    bool insideQuotes = false;
    String? quoteChar;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (insideQuotes) {
        if (char == '\\' && i + 1 < line.length) {
          // Manejar escapes
          buffer.write(line[++i]);
        } else if (char == quoteChar) {
          insideQuotes = false;
          quoteChar = null;
        } else {
          buffer.write(char);
        }
      } else {
        if ((char == '"' || char == "'")) {
          insideQuotes = true;
          quoteChar = char;
        } else if (char == ',') {
          result.add(buffer.toString().trim());
          buffer.clear();
        } else {
          buffer.write(char);
        }
      }
    }

    // Agregar el último campo
    if (buffer.isNotEmpty || line.endsWith(',')) {
      result.add(buffer.toString().trim());
    }

    return result;
  }
}
