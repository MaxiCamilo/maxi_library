import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

mixin ISemaphore {
  Future<bool> get checkIfLocker;

  Future<T> execute<T>({required FutureOr<T> Function() function});
  Stream<T> executeStream<T>({required Stream<T> stream});
  Stream<T> executeFutureStream<T>({required FutureOr<Stream<T>> Function() function});
  Future<T?> executeIfStopped<T>({required FutureOr<T> Function() function});
  void cancel();
  Future<void> awaitFullCompletion();
  Future<T> executeOnlyIsFree<T>({required FutureOr<T> Function() function});

  Completer<void> buildLocker({Duration? timeout}) {
    final locker = MaxiCompleter();

    scheduleMicrotask(() async {
      try {
        await execute(function: () => timeout == null ? locker.future : locker.future.timeout(timeout, onTimeout: () => null));
      } catch (ex) {
        locker.completeErrorIfIncomplete(ex);
      }
    });

    return locker;
  }

  Future<Completer<void>> buildAsyncLocker({Duration? timeout}) async {
    final locker = MaxiCompleter();
    final makeTurn = MaxiCompleter();

    scheduleMicrotask(() async {
      try {
        await execute(function: () async {
          makeTurn.completeIfIncomplete(null);
          await (timeout == null ? locker.future : locker.future.timeout(timeout, onTimeout: () => null));
        });
      } catch (ex) {
        locker.completeErrorIfIncomplete(ex);
      }
    });

    await makeTurn.future;
    return locker;
  }
}
