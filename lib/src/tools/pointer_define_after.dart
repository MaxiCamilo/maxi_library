import 'package:maxi_library/maxi_library.dart';

class PointerDefineAfter<T> {
  final bool onlyDefinedOnce;

  T? _item;

  PointerDefineAfter({this.onlyDefinedOnce = true});

  T get value {
    if (_item == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: tr('A value has not yet been defined in this variable'),
      );
    } else {
      return _item!;
    }
  }

  void defineValue({required T item, bool skipIfDefined = false}) {
    if (_item != null && onlyDefinedOnce) {
      if (skipIfDefined) {
        return;
      }
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: tr('A value has already been defined in this variable'),
      );
    }

    if (_item != null && skipIfDefined) {
      return;
    }

    _item = item;
  }
}
