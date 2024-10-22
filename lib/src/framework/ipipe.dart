import 'dart:async';

mixin IPipe<R, S> implements StreamSink<S> {
  bool get isActive;

  Stream<R> get stream;

  void addIfActive(S item) {
    if (isActive) {
      add(item);
    }
  }
}
