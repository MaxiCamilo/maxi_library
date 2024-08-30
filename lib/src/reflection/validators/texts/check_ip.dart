import 'package:maxi_library/maxi_library.dart';

enum CheckIpType { both, onlyIpv4, onlyIpv6 }

class CheckIp extends ValueValidator {
  final CheckIpType verificationType;
  final bool acceptLocalhost;

  const CheckIp({this.verificationType = CheckIpType.both, this.acceptLocalhost = true});

  @override
  String get formalName => tr('Valid IP checker');

  @override
  NegativeResult? performValidation({required String name, required item, required parentEntity}) {
    if (item is! String) {
      throw NegativeResultValue(
        message: trc('The property %1 only accepts text value', [name]),
        name: name,
        value: item,
      );
    }

    if (item == 'localhost') {
      if (!acceptLocalhost) {
        throw NegativeResultValue(
          message: trc('The property %1 only accepts ip addresses, not the textual value "localhost"', [name]),
          name: name,
          value: item,
        );
      }

      return null;
    }

    return switch (verificationType) {
      CheckIpType.both => _validate(name, item),
      CheckIpType.onlyIpv4 => _validateIpv4(name, item),
      CheckIpType.onlyIpv6 => _validateIpv6(name, item),
    };
  }

  static bool isIpv4(String value) {
    final RegExp ipv4RegExp = RegExp(r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
    return ipv4RegExp.hasMatch(value);
  }

  static bool isIpv6(String value) {
    final RegExp ipv6RegExp = RegExp(r'^(([0-9a-fA-F]{1,4}):){7}([0-9a-fA-F]{1,4})$');

    return ipv6RegExp.hasMatch(value);
  }

  NegativeResult? _validate(String name, String item) {
    if (!isIpv4(item) && !isIpv6(item)) {
      throw NegativeResultValue(
        message: trc('The property %1 is not a Ip Address valid', [name]),
        name: name,
        value: item,
      );
    }

    return null;
  }

  NegativeResult? _validateIpv4(String name, String item) {
    if (!isIpv4(item)) {
      throw NegativeResultValue(
        message: trc('The property %1 is not a Ipv4 Address valid', [name]),
        name: name,
        value: item,
      );
    }

    return null;
  }

  NegativeResult? _validateIpv6(String name, String item) {
    if (!isIpv4(item)) {
      throw NegativeResultValue(
        message: trc('The property %1 is not a Ipv6 Address valid', [name]),
        name: name,
        value: item,
      );
    }

    return null;
  }
}
