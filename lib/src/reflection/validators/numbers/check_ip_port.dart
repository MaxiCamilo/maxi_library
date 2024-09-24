import 'package:maxi_library/maxi_library.dart';

class CheckIpPort extends ValueValidator {
  final bool acceptZero;

  const CheckIpPort({required this.acceptZero});

  @override
  String get formalName => tr('Check port number').toString();

  @override
  NegativeResult? performValidation({required String name, required item, required parentEntity}) {
    final minimum = acceptZero ? 0 : 1;
    return CheckNumberRange(minimum: minimum, maximum: 65535).performValidation(name: name, item: item, parentEntity: parentEntity);
  }
}
