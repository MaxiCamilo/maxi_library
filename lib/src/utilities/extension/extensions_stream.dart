import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

extension IteratorStream<T> on Stream<T> {
  Future<void> waitFinish({
    bool errorsAreFatal = true,
    void Function(T)? reactionItem,
    void Function(dynamic)? reactionError,
  }) {
    final waiter = Completer();

    listen((x) {
      if (reactionItem != null) {
        reactionItem(x);
      }
    }, onDone: () {
      if (!waiter.isCompleted) {
        waiter.complete();
      }
    }, onError: (x) {
      if (reactionError != null) {
        reactionError(x);
      }

      if (errorsAreFatal && !waiter.isCompleted) {
        waiter.completeError(x);
      }
    });

    return waiter.future;
  }

  Future<T> waitItem() {
    final waiter = Completer<T>();
    late final StreamSubscription<T> subscription;

    subscription = listen(
      (x) {
        subscription.cancel();
        waiter.complete(x);
      },
      onError: (x) {
        subscription.cancel();
        waiter.completeError(x);
      },
      onDone: () {
        subscription.cancel();
        waiter.completeError(
          NegativeResult(
            identifier: NegativeResultCodes.functionalityCancelled,
            message: tr('The stream was expected to return an item, but the stream was closed'),
          ),
        );
      },
    );

    return waiter.future;
  }

  Future<T?> waitSomething() {
    final waiter = Completer<T?>();
    late final StreamSubscription<T> subscription;

    subscription = listen(
      (x) {
        subscription.cancel();
        waiter.complete(x);
      },
      onError: (x) {
        subscription.cancel();
        waiter.complete(null);
      },
      onDone: () {
        subscription.cancel();
        waiter.complete(null);
      },
    );

    return waiter.future;
  }
}
