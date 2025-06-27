import 'package:maxi_library/maxi_library.dart';

class CheckTextLength extends ValueValidator {
  final num maximum;
  final num minimum;

  final int? maximumLines;
  final int? minimumLines;

  final int? maximumLengthByLine;
  final int? minimumLengthByLine;

  const CheckTextLength({
    this.minimum = double.negativeInfinity,
    this.maximum = double.infinity,
    this.maximumLines,
    this.minimumLines,
    this.maximumLengthByLine,
    this.minimumLengthByLine,
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

      if (minimumLines != null && (minimumLines! > lines && !(minimumLines == 1 && lines == 0))) {
        return NegativeResultValue(
          message: Oration(message: 'The property %1 requires at least %2 lines', textParts: [name, minimumLines!]),
          formalName: formalName,
          name: name,
          value: item,
        );
      }
    }

    if (maximumLengthByLine != null || minimumLengthByLine != null) {
      final textSplit = item.split('\n');

      int i = 1;
      for (final text in textSplit) {
        if (maximumLengthByLine != null && text.length > maximumLengthByLine!) {
          return NegativeResultValue(
            message: Oration(
              message: 'Line %1 of property %2 is %3 characters long, but a maximum of %4 characters is accepted',
              textParts: [i, name, text.length, maximumLengthByLine!],
            ),
            formalName: formalName,
            name: name,
            value: item,
          );
        }

        if (minimumLengthByLine != null && text.length < minimumLengthByLine!) {
          return NegativeResultValue(
            message: Oration(
              message: 'Line %1 of property %2 is %3 characters long, but it needs to be at least %4 characters long',
              textParts: [i, name, text.length, minimumLengthByLine!],
            ),
            formalName: formalName,
            name: name,
            value: item,
          );
        }

        i += 1;
      }
    }

    return null;
  }
}
