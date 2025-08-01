import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';

class GeneratorList<T> with IValueGenerator, IReflectionType, IPrimitiveValueGenerator, IListValueGenerator {
  @override
  final List annotations;

  const GeneratorList({this.annotations = const []});

  @override
  Type get type => List<T>;

  @override
  String get name => 'List<$T>';

  @override
  bool isCompatible(item) {
    return item is Iterable;
  }

  @override
  generateEmptryObject() {
    return <T>[];
  }

  @override
  Oration get description => Description.searchDescription(annotations: annotations);

  @override
  convertObject(originalItem) {
    if (originalItem is Iterable<T>) {
      return originalItem.toList();
    } else if (originalItem is Iterable) {
      final newList = <T>[];
      int i = 1;
      for (final part in originalItem) {
        if (part is T) {
          newList.add(part);
        } else if (part is Map<String, dynamic>) {
          newList.add(ReflectionManager.interpret<T>(value: part, tryToCorrectNames: true));
        } else {
          throw NegativeResult(
            identifier: NegativeResultCodes.wrongType,
            message: Oration(message: 'The item N° %1 is %2, but only objects of type $T are accepted (and it is incompatible)', textParts: [i, part.runtimeType]),
          );
        }
      }

      return newList;
    } else if (originalItem is T) {
      return [originalItem];
    } else if (originalItem is String) {
      return interpretPrimitiveValue(originalItem);
    }

    throw NegativeResult(
      identifier: NegativeResultCodes.wrongType,
      message: Oration(message: 'It was about adapting a value to a list of type %1, but it But it is not a valid type for the list (it is %2)', textParts: [T, originalItem.runtimeType]),
    );
  }

  @override
  bool isTypeCompatible(Type type) {
    return type == (List<T>) || type == List || type == (Iterable<T>) || type == Iterable || type == T;
  }

  @override
  serializeToMap(item) {
    if (item is! Iterable) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(message: 'A list of type %1 was expected (The object is %2)', textParts: [T, item.runtimeType]),
      );
    }

    if (item.isEmpty) {
      return [];
    }

    final allTypesAreSame = item.every((x) => x.runtimeType == T);
    if (allTypesAreSame) {
      return _serializeListSameType(item);
    } else {
      return _serializeListDifferentTypes(item);
    }
  }

  List<Map<String, dynamic>> _serializeListSameType(Iterable list) {
    final typeOperator = ReflectionManager.getReflectionType(T, annotations: []);
    int i = 1;

    final newList = <Map<String, dynamic>>[];

    for (final item in list) {
      final newItem = addToErrorDescription(
        additionalDetails: Oration(message: 'Item N° %1', textParts: [i]),
        function: () => typeOperator.serializeToMap(item),
      );
      newList.add(newItem);
      i += 1;
    }

    return newList;
  }

  List<Map<String, dynamic>> _serializeListDifferentTypes(Iterable list) {
    int i = 1;

    IReflectionType? typeOperator;

    final newList = <Map<String, dynamic>>[];

    for (final item in list) {
      if (typeOperator == null || typeOperator.type != item.runtimeType) {
        typeOperator = addToErrorDescription(
          additionalDetails: Oration(message: 'Item N° %1', textParts: [i]),
          function: () => ReflectionManager.getReflectionType(item.runtimeType, annotations: []),
        );
      }

      final newItem = addToErrorDescription(
        additionalDetails: Oration(message: 'Item N° %1', textParts: [i]),
        function: () => typeOperator!.serializeToMap(item),
      );
      newList.add(newItem);
      i += 1;
    }

    return newList;
  }

  @override
  cloneObject(originalItem) {
    if (originalItem! is Iterable) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(message: 'A list of type $T was expected (The object is %2)', textParts: [T, originalItem.runtimeType]),
      );
    }

    int i = 1;
    IReflectionType? typeOperator;
    final newList = <T>[];

    for (final item in originalItem) {
      if (typeOperator == null || typeOperator.type != item.runtimeType) {
        typeOperator = addToErrorDescription(
          additionalDetails: Oration(message: 'Item N° %1', textParts: [i]),
          function: () => ReflectionManager.getReflectionType(item.runtimeType, annotations: []),
        );
      }

      final newItem = addToErrorDescription(
        additionalDetails: Oration(message: 'Item N° %1', textParts: [i]),
        function: () => typeOperator!.cloneObject(item),
      );
      newList.add(newItem);
      i += 1;
    }

    return newList;
  }

  bool areSame({required dynamic first, required dynamic second}) {
    final firstList = first as List;
    final secondList = second as List;

    if (firstList.length != secondList.length) {
      return false;
    }

    for (int i = 0; i < firstList.length; i++) {
      final firtsValue = firstList[i];
      final secondValue = secondList[i];

      if (!ReflectionManager.areSame(first: firtsValue, second: secondValue)) {
        return false;
      }
    }

    return true;
  }

  @override
  PrimitiesType get primitiveType => PrimitiesType.isString;

  @override
  convertToPrimitiveValue(value) {
    final result = serializeToMap(value);
    return json.encode(result);
  }

  @override
  convertToListValue(value) {
    return serializeToMap(value);
  }

  @override
  interpretPrimitiveValue(value) {
    if (T == NegativeResult || T == NegativeResultValue) {
      return _parseNegativeResult(value);
    }

    final jsonValue = json.decode(value);
    final reflector = ReflectionManager.getReflectionEntity(T);

    if (jsonValue is Iterable) {
      final list = <T>[];
      for (final item in jsonValue) {
        if (item is String) {
          list.add(reflector.interpretationFromJson(rawJson: item, tryToCorrectNames: true));
        } else if (item is Map<String, dynamic>) {
          list.add(reflector.interpret(value: item, tryToCorrectNames: true));
        } else {
          throw NegativeResult(identifier: NegativeResultCodes.invalidValue, message: const Oration(message: 'Item list must be a String or Map Value'));
        }
      }
      return list;
    } else {
      return [reflector.interpretationFromJson(rawJson: jsonValue, tryToCorrectNames: true)];
    }
  }

  List<T> _parseNegativeResult(dynamic value) {
    late final dynamic rawContent;
    if (value is String) {
      final jsonValue = ConverterUtilities.interpretJson(text: value);
      rawContent = jsonValue;
    } else {
      rawContent = value;
    }

    if (rawContent is Map<String, dynamic>) {
      return [NegativeResult.interpret(values: rawContent, checkTypeFlag: true) as T];
    } else if (rawContent is List) {
      return rawContent.map((x) => NegativeResult.interpret(values: x, checkTypeFlag: true) as T).toList();
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: const Oration(message: 'Negative result can only be interpreted from an object or list'),
      );
    }
  }
}
