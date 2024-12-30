import 'package:maxi_library/maxi_library.dart';

class CheckIpPort extends ValueValidator {
  final bool acceptZero;

  const CheckIpPort({required this.acceptZero});

  @override
  TranslatableText get formalName => const TranslatableText(message: 'Check port number');

  @override
  NegativeResult? performValidation({required TranslatableText formalName, required String name, required item, required parentEntity}) {
    final minimum = acceptZero ? 0 : 1;
    return CheckNumberRange(minimum: minimum, maximum: 65535).performValidation(formalName: formalName, name: name, item: item, parentEntity: parentEntity);
  }
}
