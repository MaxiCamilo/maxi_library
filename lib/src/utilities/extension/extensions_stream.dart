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

  Future<T> waitItem({
    Duration? timeout,
    T Function()? onTimeout,
  }) async {
    final waiter = Completer<T>();
    late final StreamSubscription<T> subscription;

    subscription = listen(
      (x) {
        subscription.cancel();
        waiter.completeIfIncomplete(x);
      },
      onError: (x) {
        subscription.cancel();
        waiter.completeError(x);
      },
      onDone: () {
        subscription.cancel();
        waiter.completeErrorIfIncomplete(
          NegativeResult(
            identifier: NegativeResultCodes.functionalityCancelled,
            message: Oration(message: 'The stream was expected to return an item, but the stream was closed'),
          ),
        );
      },
    );

    Timer? timer;

    if (timeout != null) {
      timer = Timer(timeout, () {
        if (onTimeout == null) {
          waiter.completeErrorIfIncomplete(NegativeResult(
            identifier: NegativeResultCodes.timeout,
            message: const Oration(message: 'It took too long to receive an item in the data stream'),
          ));
        } else {
          try {
            waiter.completeIfIncomplete(onTimeout());
          } catch (ex, st) {
            waiter.completeErrorIfIncomplete(ex, st);
          }
        }
        subscription.cancel();
      });
    }

    try {
      return await waiter.future;
    } finally {
      timer?.cancel();
      subscription.cancel();
    }
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

  Stream<T> parallelizingStreamWithFuture<F>({
    required Future<F> Function() function,
    void Function(F x)? onFuntionResult,
    bool cancelFutureIfStreamClose = true,
    bool closeStreamIfFutureFinish = true,
  }) {
    bool streamFinish = false;
    bool futureFinish = false;

    final controller = StreamController<T>();

    late final Future future;
    final subscription = listen(
      (x) => controller.add(x),
      onError: (x, y) {
        controller.addError(x, y);
      },
      onDone: () {
        streamFinish = true;
        if (futureFinish) {
          controller.close();
        } else if (cancelFutureIfStreamClose) {
          future.ignore();
          controller.close();
        }
      },
    );

    future = function().then((x) {
      if (onFuntionResult != null) {
        onFuntionResult(x);
      }
    }).onError((x, y) {
      controller.addError(x!, y);
    }).whenComplete(() {
      futureFinish = true;
      if (streamFinish) {
        controller.close();
      } else if (closeStreamIfFutureFinish) {
        subscription.cancel();
        controller.close();
      }
    });

    return controller.stream;
  }
}
