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
    required dynamic item,
    required String propertyName,
    required String actionDescription,
    dynamic value,
    NegativeResultCodes codeDescription = NegativeResultCodes.externalFault,
  }) {
    if (item is NegativeResultValue) {
      return item;
    } else if (item is NegativeResult) {
      return NegativeResultValue(
        identifier: item.identifier,
        name: propertyName,
        message: item.message,
        cause: item.cause,
        whenWas: item.whenWas,
        value: value,
      );
    } else {
      return NegativeResultValue(
        identifier: codeDescription,
        name: propertyName,
        message: trc('The functionality %1 in the property $propertyName failed', [actionDescription]),
        cause: item,
        value: value,
      );
    }
  }
}
