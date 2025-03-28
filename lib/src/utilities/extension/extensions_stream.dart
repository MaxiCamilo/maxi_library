import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

extension IteratorStream<T> on Stream<T> {
  Future<void> waitFinish({
    bool errorsAreFatal = true,
    void Function(T)? reactionItem,
    void Function(dynamic)? reactionError,
    List<Future> finished = const [],
  }) {
    final waiter = Completer();

    final subscription = listen((x) {
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

    for (final item in finished) {
      item.whenComplete(() {
        subscription.cancel();
        finished.iterar((x) => x.ignore());
      });
    }

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
            message: Oration(message: 'The stream was expected to return an item, but the stream was closed'),
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

  void repeatWithController({required StreamSink<T> repeater, bool closeToo = true}) {
    final subscription = listen(
      (event) => repeater.add(event),
      onError: (x, y) => repeater.addError(x, y),
      onDone: () {
        if (closeToo) {
          repeater.close();
        }
      },
    );

    repeater.done.whenComplete(() => subscription.cancel());
  }

  Stream<dynamic> streamEntitiesViaJson({required bool tryToCorrectName}) async* {
    await for (final value in this) {
      if (value is! String) {
        continue;
      }

      if (value.startsWith('{') && value.endsWith('}')) {
        yield ReflectionManager.tryToInterpretFromUnknownJson(rawJson: value, tryToCorrectNames: tryToCorrectName);
      } else if (value.startsWith('[') && value.endsWith(']')) {
        yield ReflectionManager.tryToInterpretFromUnknownJsonList(rawJson: value, tryToCorrectNames: tryToCorrectName);
      }
    }
  }

  Stream<T> whereAsync(Future<bool> Function(T) function) async* {
    await for (final item in this) {
      if (await function(item)) {
        yield item;
      }
    }
  }
}
