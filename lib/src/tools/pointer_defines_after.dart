import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';

class PointerDefineAfter<T> {
  final bool onlyDefinedOnce;

  Completer<T>? _waiterValue;

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

  Future<T> waitValue({bool ifModifies = false}) async {
    if (!ifModifies && _item != null) {
      return _item!;
    }

    _waiterValue ??= MaxiCompleter<T>();
    return await _waiterValue!.future;
  }

  void defineValue({required T item, bool skipIfDefined = false}) {
    if (_item != null && onlyDefinedOnce) {
      if (skipIfDefined) {
        if (_waiterValue != null) {
          log('[PointerDefineAfter] The change of value was expected, but it was omitted!');
        }
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
    _waiterValue?.completeIfIncomplete(item);
    _waiterValue = null;
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
