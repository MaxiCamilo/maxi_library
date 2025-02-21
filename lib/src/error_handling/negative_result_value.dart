import 'package:maxi_library/maxi_library.dart';

class NegativeResultValue extends NegativeResult {
  Oration formalName;
  String name;
  dynamic value;
  List<NegativeResultValue> invalidProperties;

  static const String labelType = 'error.value';

  NegativeResultValue({
    required super.message,
    required this.name,
    required this.formalName,
    super.identifier = NegativeResultCodes.invalidProperty,
    super.cause,
    super.whenWasIt,
    this.value,
    List<NegativeResultValue>? invalidProperties,
  }) : invalidProperties = invalidProperties ?? [];

  factory NegativeResultValue.fromNegativeResult({
    required String name,
    required Oration formalName,
    required NegativeResult nr,
    dynamic value,
    List<NegativeResultValue>? invalidProperties,
  }) {
    if (nr is NegativeResultValue) {
      return nr;
    }

    return NegativeResultValue(
      formalName: formalName,
      message: nr.message,
      name: name,
      identifier: nr.identifier,
      value: value,
      cause: nr.cause,
      whenWasIt: nr.whenWasIt,
      invalidProperties: invalidProperties,
    );
  }

  factory NegativeResultValue.fromException({
    required String name,
    required Oration formalName,
    required dynamic ex,
    dynamic value,
  }) {
    return NegativeResultValue.fromNegativeResult(
      formalName: formalName,
      name: name,
      value: value,
      nr: NegativeResult.searchNegativity(item: ex, actionDescription: Oration(message: 'Vefify value named %1', textParts: [name])),
    );
  }

  @override
  Map<String, dynamic> serialize() {
    final map = super.serialize();

    map['\$type'] = labelType;
    map['name'] = name.toString();
    map['formalName'] = formalName.serializeToJson();
    map['invalidProperties'] = invalidProperties.map<Map<String, dynamic>>((x) => x.serialize()).toList();

    if (value != null) {
      map['value'] = value.toString();
    }

    return map;
  }

  static NegativeResultValue searchNegativity({
    required dynamic error,
    required String name,
    required Oration formalName,
    dynamic value,
    NegativeResultCodes codeDescription = NegativeResultCodes.externalFault,
  }) {
    if (error is NegativeResultValue) {
      return error;
    } else if (error is NegativeResult) {
      return NegativeResultValue(
        identifier: error.identifier,
        formalName: formalName,
        name: name,
        message: error.message,
        cause: error.cause,
        whenWasIt: error.whenWasIt,
        value: value,
      );
    } else {
      return NegativeResultValue(
        identifier: codeDescription,
        formalName: formalName,
        name: name,
        message: Oration(message: 'The validation for property %1 failed with the following error: "%2"', textParts: [formalName, error.toString()]),
        cause: error,
        value: value,
      );
    }
  }

  factory NegativeResultValue.interpretJson({required String jsonText, bool checkTypeFlag = true}) =>
      NegativeResultValue.interpret(values: ConverterUtilities.interpretToObjectJson(text: jsonText), checkTypeFlag: checkTypeFlag);

  factory NegativeResultValue.interpret({required Map<String, dynamic> values, required bool checkTypeFlag}) {
    if (checkTypeFlag && (!values.containsKey('\$type') || values['\$type'] is! String || (values['\$type']! as String) != labelType)) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(message: '"Negative results Value" are invalid or do not have their type label'),
      );
    }

    final invalidProperties = <NegativeResultValue>[];

    for (final item in volatileProperty(formalName: const Oration(message: 'Invalid Properties'), propertyName: 'invalidProperties', function: () => values['invalidProperties']! as Iterable)) {
      try {
        if (item is Map<String, dynamic>) {
          invalidProperties.add(NegativeResultValue.interpret(values: item, checkTypeFlag: true));
        } else if (item is String) {
          invalidProperties.add(NegativeResultValue.interpretJson(jsonText: item, checkTypeFlag: true));
        } else {
          throw NegativeResult(identifier: NegativeResultCodes.invalidValue, message: const Oration(message: 'The invalid properties must be a String or Map<String,dynamic>'));
        }
      } catch (ex) {
        throw NegativeResult.searchNegativity(item: ex, actionDescription: const Oration(message: 'Interpreting the invalid properties of a negative result'));
      }
    }

    return NegativeResultValue(
      message: Oration.interpretFromJson(text: volatileProperty(propertyName: 'message', formalName: const Oration(message: 'Error message'), function: () => values['message']!)),
      identifier: volatileProperty(propertyName: 'identifier', formalName: const Oration(message: 'Error Identifier'), function: () => NegativeResultCodes.values[(( values['identifier'] ?? values['idError'])! as int)]),
      name: volatileProperty(propertyName: 'name', formalName: const Oration(message: 'Entity name'), function: () => values['name']!),
      formalName: volatileProperty(propertyName: 'formalName', formalName: const Oration(message: 'Formal name of Entity'), function: () => Oration.interpretFromJson(text: values['formalName']!)),
      whenWasIt:
          DateTime.fromMillisecondsSinceEpoch(volatileProperty(propertyName: 'whenWasIt', formalName: const Oration(message: 'Error date and time'), function: () => values['whenWasIt']! as int), isUtc: true).toLocal(),
      invalidProperties: invalidProperties,
    );
  }
}
