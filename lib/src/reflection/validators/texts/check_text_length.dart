import 'package:maxi_library/maxi_library.dart';

class CheckTextLength extends ValueValidator {
  final num maximum;
  final num minimum;

  final int? maximumLines;
  final int? minimumLines;

  const CheckTextLength({
    this.minimum = double.negativeInfinity,
    this.maximum = double.infinity,
    this.maximumLines,
    this.minimumLines,
  });

  @override
  Oration get formalName => const Oration(message: 'Length of the text');

  @override
  NegativeResult? performValidation({required Oration formalName, required String name, required item, required parentEntity}) {
    if (item is! String) {
      return NegativeResultValue(
        message: Oration(message: 'The property %1 only accepts text value', textParts: [name]),
        formalName: formalName,
        name: name,
        value: item,
      );
    }

    if (minimum > 0 && item.isEmpty) {
      return NegativeResultValue(
        message: Oration(message: 'The property %1 does not accept empty texts', textParts: [name]),
        formalName: formalName,
        name: name,
        value: item,
      );
    }

    if (item.length < minimum) {
      return NegativeResultValue(
        message: Oration(message: 'The property %1 requires at least %2 characters', textParts: [name, minimum]),
        formalName: formalName,
        name: name,
        value: item,
      );
    }

    if (item.length > maximum) {
      return NegativeResultValue(
        message: Oration(message: 'The property %1 only accepts text with a maximum of %2 characters', textParts: [name, maximum]),
        formalName: formalName,
        name: name,
        value: item,
      );
    }

    if (maximumLines != null || minimumLines != null) {
      final lines = '\n'.allMatches(item).length;

      if (maximumLines != null && maximumLines! < lines) {
        return NegativeResultValue(
          message: Oration(message: 'The property %1 only accepts text with a maximum of %2 lines', textParts: [name, maximumLines!]),
          formalName: formalName,
          name: name,
          value: item,
        );
      }

      if (minimumLines != null && minimumLines! > lines) {
        return NegativeResultValue(
          message: Oration(message: 'The property %1 requires at least %2 lines', textParts: [name, minimumLines!]),
          formalName: formalName,
          name: name,
          value: item,
        );
      }
    }

    return null;
  }
}
