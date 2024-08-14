import 'package:maxi_library/maxi_library.dart';

class NegativeResultValue extends NegativeResult {
  String name;
  dynamic value;

  NegativeResultValue({
    required super.message,
    required this.name,
    super.identifier = NegativeResultCodes.invalidProperty,
    super.cause,
    super.whenWas,
    this.value,
  });

  factory NegativeResultValue.fromNegativeResult({required String name, required NegativeResult nr, dynamic value}) {
    if (nr is NegativeResultValue) {
      return nr;
    }

    return NegativeResultValue(
      message: nr.message,
      name: name,
      identifier: nr.identifier,
      value: value,
      cause: nr.cause,
      whenWas: nr.whenWas,
    );
  }

  @override
  Map<String, dynamic> serialize() {
    final map = super.serialize();
    map['name'] = name;

    if (value != null) {
      map['value'] = value.toString();
    }

    return map;
  }

  static NegativeResultValue searchNegativity({
    required dynamic error,
    required String propertyName,
    dynamic value,
    NegativeResultCodes codeDescription = NegativeResultCodes.externalFault,
  }) {
    if (error is NegativeResultValue) {
      return error;
    } else if (error is NegativeResult) {
      return NegativeResultValue(
        identifier: error.identifier,
        name: propertyName,
        message: error.message,
        cause: error.cause,
        whenWas: error.whenWas,
        value: value,
      );
    } else {
      return NegativeResultValue(
        identifier: codeDescription,
        name: propertyName,
        message: trc('The validation for property %1 failed with the following error: "%2"', [propertyName, error.toString()]),
        cause: error,
        value: value,
      );
    }
  }
}
