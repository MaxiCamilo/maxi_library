import 'package:maxi_library/maxi_library.dart';

class PointerDefineAfter<T> {
  final bool onlyDefinedOnce;

  T? _item;

  bool get defined => _item != null;

  PointerDefineAfter({this.onlyDefinedOnce = true});

  T get value {
    if (_item == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: Oration(message: 'A value has not yet been defined in this variable'),
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
        message: Oration(message: 'A value has already been defined in this variable'),
      );
    }

    if (_item != null && skipIfDefined) {
      return;
    }

    _item = item;
  }

  void dispose() {
    if (_item != null) {
      /*
      try {
        (_item as dynamic).dispose();
      } catch (_) {}
      */
      _item = null;
    }
  }
}
