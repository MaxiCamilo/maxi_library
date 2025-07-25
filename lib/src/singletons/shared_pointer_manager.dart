import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class SharedPointerManager {
  int _lastID = 1;

  final _valuesMap = <int, dynamic>{};
  final _notifyItemEliminated = StreamController<int>.broadcast();

  static final SharedPointerManager singleton = SharedPointerManager._();

  Stream<int> get notifyItemEliminated => _notifyItemEliminated.stream;

  SharedPointerManager._();

  int addItem(dynamic value) {
    final id = _lastID;
    _lastID += 1;

    _valuesMap[id] = value;

    

    return id;
  }

  T getItem<T>({required int identifier}) {
    final item = _valuesMap[identifier];
    if (item == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: Oration(
          message: 'The thread does not have the number %1 value',
          textParts: [identifier],
        ),
      );
    }

    if (item is T) {
      return item;
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(
          message: 'The shared value number %1 is %2, but it was expected by %3',
          textParts: [identifier, item.runtimeType, T],
        ),
      );
    }
  }

  void removeItem({required int identifier}) {
    _valuesMap.remove(identifier);
    _notifyItemEliminated.add(identifier);
  }
}
