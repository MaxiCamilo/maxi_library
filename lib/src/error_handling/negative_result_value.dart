import 'package:maxi_library/maxi_library.dart';

class NegativeResultValue extends NegativeResult {
  Oration formalName;
  String name;
  dynamic value;

  NegativeResultValue({
    required super.message,
    required this.name,
    required this.formalName,
    super.identifier = NegativeResultCodes.invalidProperty,
    super.cause,
    super.whenWasIt,
    this.value,
  });

  factory NegativeResultValue.fromNegativeResult({required String name, required Oration formalName, required NegativeResult nr, dynamic value}) {
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

    map['\$type'] = 'error.value';
    map['name'] = name.toString();

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
}
