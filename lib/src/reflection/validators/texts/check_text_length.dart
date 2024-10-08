import 'package:maxi_library/maxi_library.dart';

class CheckTextLength extends ValueValidator {
  final num maximum;
  final num minimum;

  const CheckTextLength({
    this.minimum = double.negativeInfinity,
    this.maximum = double.infinity,
  });

  @override
  String get formalName => tr('Length of the text').toString();

  @override
  NegativeResult? performValidation({required String name, required item, required parentEntity}) {
    if (item is! String) {
      return NegativeResultValue(
        message: tr('The property %1 only accepts text value', [name]),
        name: tr(name),
        value: item,
      );
    }

    if (minimum > 0 && item.isEmpty) {
      return NegativeResultValue(
        message: tr('The property %1 does not accept empty texts', [name]),
        name: tr(name),
        value: item,
      );
    }

    if (item.length < minimum) {
      return NegativeResultValue(
        message: tr('The property %1 requires at least %2 characters', [name, minimum]),
        name: tr(name),
        value: item,
      );
    }

    if (item.length > maximum) {
      return NegativeResultValue(
        message: tr('The property %1 only accepts text with a maximum of %2 characters', [name, maximum]),
        name: tr(name),
        value: item,
      );
    }

    return null;
  }
}
