import 'dart:convert';
import 'dart:typed_data';

import 'package:maxi_library/maxi_library.dart';

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

  static dynamic interpretJson({required String text, Oration? extra}) {
    return volatile(detail: extra == null ? Oration(message: 'The content is not valid json') : Oration(message: 'The content is not valid json %1', textParts: [extra]), function: () => json.decode(text));
  }

  static Map<String, dynamic> interpretToObjectJson({required String text, Oration? extra}) {
    return volatile(
        detail: extra == null ? Oration(message: 'Expected a json object, but received a json listing or value') : Oration(message: 'Expected a json object, but received a json listing or value %1', textParts: [extra]),
        function: () => interpretJson(text: text, extra: extra) as Map<String, dynamic>);
  }

  static List<Map<String, dynamic>> interpretToObjectListJson({required String text, Oration? extra}) {
    return volatile(
        detail: extra == null
            ? Oration(message: 'Expected a list of json objects, but received a json list with an unknown value or a single value')
            : Oration(message: 'Expected a json object, but received a json listing or value %1', textParts: [extra]),
        function: () => (interpretJson(text: text, extra: extra) as List).cast<Map<String, dynamic>>()).toList();
  }

  static String toJsonString(dynamic item) => volatile(detail: const Oration(message: 'The entered value cannot be converted to JSON text'), function: () => json.encode(item));
}
