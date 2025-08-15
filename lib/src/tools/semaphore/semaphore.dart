import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class Semaphore with ISemaphore {
  final _waitingList = <(Completer, FutureOr Function(), StackTrace)>[];
  final _waitingStreamList = <(StreamController, FutureOr<Stream> Function(), StackTrace)>[];

  bool get isActive => _isActive;

  @override
  Future<bool> get checkIfLocker async => isActive;

  bool _isActive = false;

  int get pendingLength => _waitingList.length + _waitingStreamList.length;
  bool get nextIsBusy => pendingLength - 1 > 0;

  @override
  Future<T> execute<T>({required FutureOr<T> Function() function}) {
    final waiter = MaxiCompleter<T>();
    _waitingList.add((waiter, function, StackTrace.current));

    if (!_isActive) {
      _isActive = true;
      maxiScheduleMicrotask(_runSemaphone);
    }

    return waiter.future;
  }

  @override
  Stream<T> executeStream<T>({required Stream<T> stream}) => executeFutureStream<T>(function: () => stream);

  @override
  Stream<T> executeFutureStream<T>({required FutureOr<Stream<T>> Function() function}) {
    final controller = StreamController<T>();
    _waitingStreamList.add((controller, function, StackTrace.current));

    if (!_isActive) {
      _isActive = true;
      maxiScheduleMicrotask(_runSemaphone);
    }

    return controller.stream;
  }

  @override
  Future<T?> executeIfStopped<T>({required FutureOr<T> Function() function}) async {
    if (!_isActive) {
      return await execute(function: function);
    } else {
      return null;
    }
  }

  @override
  void cancel() {
    _waitingList.iterar((x) => x.$1.completeErrorIfIncomplete(NegativeResult(identifier: NegativeResultCodes.functionalityCancelled, message: Oration(message: 'The task was canceled'))));
    _waitingList.clear();

    _waitingStreamList.iterar((x) => x.$1.close());
    _waitingStreamList.clear();
  }

  Future<void> _runSemaphone() async {
    _isActive = true;

    do {
      while (_waitingList.isNotEmpty) {
        final item = _waitingList.removeAt(0);
        try {
          final result = await item.$2();
          item.$1.completeIfIncomplete(result);
        } catch (ex, st) {
          final newSt = StackTrace.fromString('${st.toString()}\n-------------------------------------- Synchronizer Semaphor --------------------------------------\n${item.$3.toString()}');
          item.$1.completeErrorIfIncomplete(ex, newSt);
        }
      }

      while (_waitingStreamList.isNotEmpty) {
        final instance = _waitingStreamList.removeAt(0);
        late final Stream stream;

        final controller = instance.$1;
        final function = instance.$2;

        try {
          stream = await function();

          final subcription = stream.listen(
            (x) => controller.add(x),
            onError: (x, y) {
              final newSt = StackTrace.fromString('${y.toString()}\n-------------------------------------- Synchronizer Semaphor --------------------------------------\n${instance.$3.toString()}');
              controller.addError(x, newSt);
            },
            onDone: () => controller.close(),
          );

          await controller.done.whenComplete(() => subcription.cancel());
        } catch (ex, st) {
          final newSt = StackTrace.fromString('${st.toString()}\n-------------------------------------- Synchronizer Semaphor --------------------------------------\n${instance.$3.toString()}');
          controller.addError(ex, newSt);
          controller.close();
          continue;
        }
      }
    } while (_waitingList.isNotEmpty || _waitingStreamList.isNotEmpty);

    _isActive = false;
  }

  @override
  Future<void> awaitFullCompletion() async {
    while (isActive) {
      await execute(function: () {});
      await continueOtherFutures();
    }
  }

  @override
  Future<T> executeOnlyIsFree<T>({required FutureOr<T> Function() function}) async {
    await awaitFullCompletion();
    return await execute(function: function);
  }
}
