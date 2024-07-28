import 'dart:async';

class Semaphore {
  final _waitingList = <(Completer, Future Function())>[];
  bool _isActive = false;

  Future<T> execute<T>({required Future<T> Function() function}) {
    final waiter = Completer<T>();
    _waitingList.add((waiter, function));

    if (!_isActive) {
      _isActive = true;
      scheduleMicrotask(_runSemaphone);
    }

    return waiter.future;
  }

  Future<void> _runSemaphone() async {
    _isActive = true;

    while (_waitingList.isNotEmpty) {
      final item = _waitingList.removeAt(0);
      try {
        final result = item.$2();
        item.$1.complete(result);
      } catch (ex) {
        item.$1.completeError(ex);
      }
    }

    _isActive = false;
  }
}
