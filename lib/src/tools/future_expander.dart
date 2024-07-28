import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class FutureExpander<T> {
  final Future<T> Function() reservedFunction;

  final _waitingList = <Completer<T>>[];

  bool _isActive = false;

  FutureExpander({required this.reservedFunction});

  Future<T> execute() {
    final instanceWaiting = Completer<T>();
    _waitingList.add(instanceWaiting);

    if (!_isActive) {
      _isActive = true;
      scheduleMicrotask(_startFuncion);
    }

    return instanceWaiting.future;
  }

  Future<void> _startFuncion() async {
    _isActive = true;
    try {
      final result = await reservedFunction();
      _waitingList.startIteration((x) => x.complete(result));
      _waitingList.clear();
    } catch (ex) {
      _waitingList.startIteration((x) => x.completeError(ex));
      _waitingList.clear();
    }
    _isActive = false;
  }
}
