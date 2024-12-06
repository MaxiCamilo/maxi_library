import 'dart:async';

extension IteratorStreamController<T> on StreamController<T> {
  void addIfActive(T event) {
    if (!isClosed) {
      add(event);
    }
  }

  void addErrorIfActive(Object error, [StackTrace? stackTrace]) {
    if (!isClosed) {
      addError(error, stackTrace);
    }
  }
}
