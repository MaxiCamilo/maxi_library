import 'package:maxi_library/maxi_library.dart';

class TypeEnumeratorReflector with IReflectionType, IValueGenerator, IPrimitiveValueGenerator {
  final List<EnumOption> optionsList;

  @override
  final List annotations;

  @override
  final Type type;

  @override
  final String name;

  @override
  PrimitiesType get primitiveType => PrimitiesType.isInt;

  const TypeEnumeratorReflector({required this.optionsList, required this.annotations, required this.type, required this.name});

  @override
  cloneObject(originalItem) {
    return convertObject(originalItem);
  }

  @override
  convertObject(originalItem) {
    if (originalItem is Enum) {
      return castNumber(originalItem.index);
    } else if (originalItem is num) {
      return castNumber(originalItem);
    } else if (originalItem is String) {
      return castString(originalItem);
    }

    throw NegativeResult(
      identifier: NegativeResultCodes.invalidValue,
      message: tr('The value of type "%1" is not a valid option for the enumerator "%2"', [originalItem.runtimeType, type]),
    );
  }

  @override
  generateEmptryObject() {
    return optionsList.first.value;
  }

  @override
  bool isCompatible(item) {
    return item is Enum || item is num || item is String;
  }

  @override
  bool isTypeCompatible(Type type) {
    return type == this.type || type == int || type == num || type == double || type == String;
  }

  @override
  serializeToMap(item) {
    if (item is Enum) {
      return item.index;
    } else if (item is num) {
      return castNumber(item).index;
    } else if (item is String) {
      return castString(item).index;
    }

    throw NegativeResult(
      identifier: NegativeResultCodes.invalidValue,
      message: tr('The value of type  "%1" is not a valid option for the enumerator "%2"', [item.runtimeType, type]),
    );
  }

  dynamic castNumber(num number) {
    checkProgrammingFailure(thatChecks: tr('The value is zero or positive'), result: () => number >= 0);

    if (number >= optionsList.length) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidValue,
        message: tr('The numeric value exceeds the available options (Only %1 options are available, starting from 0)', [optionsList.length]),
      );
    }

    return optionsList[number.toInt()].value;
  }

  dynamic castString(String text) {
    final asInt = double.tryParse(text);
    if (asInt != null) {
      return castNumber(asInt);
    }

    final selectedItem = optionsList.selectItem((x) => x.name == text);

    if (selectedItem != null) {
      return selectedItem.value;
    } else {
      throw NegativeResult(identifier: NegativeResultCodes.invalidValue, message: tr('The option named "%1" cannot be found', [text]));
    }
  }

  @override
  String toString() => 'Enumerator $name';

  @override
  convertToPrimitiveValue(value) {
    serializeToMap(value);
  }

  @override
  interpretPrimitiveValue(value) {
    convertObject(value);
  }
}
