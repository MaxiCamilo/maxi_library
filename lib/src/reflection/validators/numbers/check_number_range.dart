import 'package:maxi_library/maxi_library.dart';

class CheckNumberRange extends ValueValidator {
  final num maximum;
  final num minimum;

  const CheckNumberRange({
    this.minimum = double.negativeInfinity,
    this.maximum = double.infinity,
  });

  @override
  Oration get formalName => const Oration(message: 'Numerical limit');

  @override
  NegativeResult? performValidation({required Oration formalName, required String name, required item, required parentEntity}) {
    if (item is! num) {
      return NegativeResultValue(
        message: Oration(message: 'The property %1 only accepts numbers', textParts:[name]),
        formalName: formalName,
        name: name,
        value: item,
      );
    }

    if (item < minimum) {
      return NegativeResultValue(
        message: Oration(message: 'The property %1 is constrained to numeric values of %2 or more', textParts:[name, minimum]),
        formalName: formalName,
        name: name,
        value: item,
      );
    }

    if (item > maximum) {
      return NegativeResultValue(
        message: Oration(message: 'The property %1 is constrained to numeric values not exceeding %2',textParts: [name, maximum]),
        formalName: formalName,
        name: name,
        value: item,
      );
    }

    return null;
  }
}
