import 'package:maxi_library/maxi_library.dart';

class ArgumentsParser {
  final List<String> rawArguments;
  final List<String> characterArguments;

  final Map<String, List<String>> argumentMap = {};

  List<String>? operator [](String key) => argumentMap[key];

  ArgumentsParser({required this.rawArguments, this.characterArguments = const ['-', '--']}) {
    String lastCharacter = '';
    List<String> content = <String>[];

    for (final item in rawArguments) {
      if (characterArguments.any((x) => item.startsWith(x))) {
        lastCharacter = item;
        if (argumentMap.containsKey(item)) {
          argumentMap[item]!.addAll(content);
        } else {
          argumentMap[item] = content;
        }
        content = <String>[];
      } else {
        content.add(item);
      }
    }

    if (content.isNotEmpty) {
      if (argumentMap.containsKey(lastCharacter)) {
        argumentMap[lastCharacter]!.addAll(content);
      } else {
        argumentMap[lastCharacter] = content;
      }
    }
  }

  String? getIndividualArgument(String key) {
    final list = this[key];
    if (list == null) {
      return null;
    }

    if (list.isEmpty) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidProperty,
        message: Oration(message: 'The argument %1 is missing a value', textParts: [key]),
      );
    }
    if (list.length > 1) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidProperty,
        message: Oration(message: 'Argument %1 only takes one value', textParts: [key]),
      );
    }

    return list[0];
  }

  int? getNumberArgument(String key) {
    final value = getIndividualArgument(key);
    if (value == null) {
      return null;
    }

    return GeneralConverter(value).toInt(propertyName: Oration(message: '', textParts: [key]));
  }
}
