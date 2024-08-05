import 'package:maxi_library/maxi_library.dart';

class NegativeResultProperty extends NegativeResult {
  String propertyName;
  dynamic value;

  NegativeResultProperty({
    required super.message,
    required this.propertyName,
    super.identifier = NegativeResultCodes.invalidProperty,
    super.cause,
    super.whenWas,
    this.value,
  });

  factory NegativeResultProperty.fromNegativeResult({required String propertyName, required NegativeResult nr, dynamic value}) {
    return NegativeResultProperty(
      message: nr.message,
      propertyName: propertyName,
      identifier: nr.identifier,
      value: value,
      cause: nr.cause,
      whenWas: nr.whenWas,
    );
  }
}
