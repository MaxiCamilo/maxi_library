import 'dart:async';


extension IteratorStream<T> on Stream<T> {
  Future<void> waitFinish() {
    final waiter = Completer();

    listen((_) {}).onDone(() => waiter.complete());

    return waiter.future;
  }
}
