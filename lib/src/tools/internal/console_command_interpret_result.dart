import 'package:maxi_library/maxi_library.dart';

class ConsoleCommandInterpretResult {
  final List<String> directCommands;
  final Map<String, List<String>> classifiedCommands;

  const ConsoleCommandInterpretResult({required this.directCommands, required this.classifiedCommands});

  bool containsClassifiedCommand(String name) => classifiedCommands.containsKey(name);

  String getDirectCommand(int position, [String? defaultValue]) {
    checkProgrammingFailure(thatChecks: const Oration(message: 'position is greater than 0'), result: () => position > 0);
    if (position > directCommands.length) {
      if (defaultValue == null) {
        throw NegativeResult(
          identifier: NegativeResultCodes.nonExistent,
          message: Oration(message: 'Console\'s arguments do not have an argument in the %1 position', textParts: [position]),
        );
      } else {
        return defaultValue;
      }
    } else {
      return directCommands[position - 1];
    }
  }

  int getDirectNumberCommand(int position, [int? defaultValue]) {
    checkProgrammingFailure(thatChecks: const Oration(message: 'position is greater than 0'), result: () => position > 0);
    if (position > directCommands.length) {
      if (defaultValue == null) {
        throw NegativeResult(
          identifier: NegativeResultCodes.nonExistent,
          message: Oration(message: 'Console\'s arguments do not have an argument in the %1 position', textParts: [position]),
        );
      } else {
        return defaultValue;
      }
    } else {
      return ConverterUtilities.toInt(
        value: directCommands[position - 1],
        ifEmptyIsZero: true,
        propertyName: Oration(message: 'Console argument number %1', textParts: [position]),
      );
    }
  }

  List<String> getClassifiedCommand(String name, [List<String>? defaultValue]) {
    final text = classifiedCommands[name];

    if (text != null) {
      return text;
    }

    if (defaultValue == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: Oration(message: 'The arguments of the console do not have an named argument called %1', textParts: [name]),
      );
    } else {
      return defaultValue;
    }
  }

  String getIndividualClassifiedCommand(String name, [String? defaultValue]) {
    final list = getClassifiedCommand(name, defaultValue == null ? null : []);

    if (list.isEmpty) {
      if (defaultValue == null) {
        throw NegativeResult(
          identifier: NegativeResultCodes.nonExistent,
          message: Oration(message: 'The arguments of the console do not have an named argument called %1', textParts: [name]),
        );
      } else {
        return defaultValue;
      }
    }

    if (list.isEmpty) {
      return '';
    } else if (list.length == 1) {
      return list.first;
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidValue,
        message: Oration(message: 'The argument named %1 has too many values, only a value is accepted', textParts: [name]),
      );
    }
  }

  int getIndividualNumberClassifiedCommand(String name, [int? defaultValue]) {
    final list = getClassifiedCommand(name, defaultValue == null ? null : []);

    if (list.isEmpty) {
      if (defaultValue == null) {
        throw NegativeResult(
          identifier: NegativeResultCodes.nonExistent,
          message: Oration(message: 'The arguments of the console do not have an named argument called %1', textParts: [name]),
        );
      } else {
        return defaultValue;
      }
    }

    if (list.isEmpty) {
      return 0;
    } else if (list.length == 1) {
      return ConverterUtilities.toInt(value: list.first, propertyName: Oration(message: 'Named argument %1', textParts: [name]));
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidValue,
        message: Oration(message: 'The argument named %1 has too many values, only a value is accepted', textParts: [name]),
      );
    }
  }
}
