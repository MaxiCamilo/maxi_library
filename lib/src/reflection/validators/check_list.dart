import 'package:maxi_library/maxi_library.dart';

class CheckList extends ValueValidator {
  final int? maximumLength;
  final int? minimumLength;
  final List<ValueValidator> validatos;

  const CheckList({this.maximumLength, this.minimumLength, this.validatos = const []});

  @override
  TranslatableText get formalName => const TranslatableText(message: 'Listing validator');

  @override
  NegativeResult? performValidation({required String name, required TranslatableText formalName, required item, required parentEntity}) {
    if (item is! Iterable) {
      return NegativeResultValue(
        message: tr('The property %1 only accepts list', [name]),
        formalName: formalName,
        name: name,
        value: item,
      );
    }

    if (maximumLength != null && maximumLength! < item.length) {
      return NegativeResultValue(
        message: tr('The list of property %1 has %2 items, but a maximum of %3 items is accepted', [name, item.length, maximumLength!]),
        formalName: formalName,
        name: name,
        value: item,
      );
    }

    if (minimumLength != null && minimumLength! > item.length) {
      return NegativeResultValue(
        message: tr('The list of property %1 has %2 items, but at least %3 items are required', [name, item.length, minimumLength!]),
        formalName: formalName,
        name: name,
        value: item,
      );
    }

    if (validatos.isNotEmpty) {
      int i = 1;
      for (final value in item) {
        for (final val in validatos) {
          final error = val.performValidation(name: '$name: Item $i', formalName: formalName, item: value, parentEntity: parentEntity);
          i++;
          if (error != null) {
            return error;
          }
        }
      }
    }

    return null;
  }
}
