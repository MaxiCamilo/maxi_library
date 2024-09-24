import 'package:maxi_library/maxi_library.dart';

class CheckNumberRange extends ValueValidator {
  final num maximum;
  final num minimum;

  const CheckNumberRange({
    this.minimum = double.negativeInfinity,
    this.maximum = double.infinity,
  });

  @override
  String get formalName => tr('Numerical limit').toString();

  @override
  NegativeResult? performValidation({required String name, required item, required parentEntity}) {
    if (item is! num) {
      return NegativeResultValue(
        message: tr('The property %1 only accepts numbers', [name]),
        name: tr( name),
        value: item,
      );
    }

    if (item < minimum) {
      return NegativeResultValue(
        message: tr('The property %1 is constrained to numeric values of %2 or more', [name, minimum]),
        name: tr( name),
        value: item,
      );
    }

    if (item > maximum) {
      return NegativeResultValue(
        message: tr('The property %1 is constrained to numeric values not exceeding %2', [name, maximum]),
        name: tr( name),
        value: item,
      );
    }

    return null;
  }
}
