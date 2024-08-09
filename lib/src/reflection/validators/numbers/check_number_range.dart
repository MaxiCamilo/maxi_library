import 'package:maxi_library/maxi_library.dart';

class CheckNumberRange extends ValueValidator {
  final num maximum;
  final num minimum;

  const CheckNumberRange({
    this.minimum = double.negativeInfinity,
    this.maximum = double.infinity,
  });

  @override
  String get formalName => tr('Numerical limit');

  @override
  NegativeResult? performValidation({required String name, required item, required parentEntity}) {
    if (item is! num) {
      return NegativeResultValue(
        message: trc('The property %1 only accepts numbers', [name]),
        name: name,
        value: item,
      );
    }

    if (item < minimum) {
      return NegativeResultValue(
        message: trc('The property %1 is constrained to numeric values of %2 or more', [name, minimum]),
        name: name,
        value: item,
      );
    }

    if (item > maximum) {
      return NegativeResultValue(
        message: trc('The property %1 is constrained to numeric values not exceeding %2', [name, maximum]),
        name: name,
        value: item,
      );
    }

    return null;
  }
}
