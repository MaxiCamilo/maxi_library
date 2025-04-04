import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class Semaphore with ISemaphore {
  final _waitingList = <(Completer, FutureOr Function())>[];
  final _waitingStreamList = <(StreamController, FutureOr<Stream> Function())>[];

  bool get isActive => _isActive;
  
  @override
  Future<bool> get checkIfLocker async => isActive;

  bool _isActive = false;

  int get pendingLength => _waitingList.length + _waitingStreamList.length;

  @override
  Future<T> execute<T>({required FutureOr<T> Function() function}) {
    final waiter = Completer<T>();
    _waitingList.add((waiter, function));

    if (!_isActive) {
      _isActive = true;
      scheduleMicrotask(_runSemaphone);
    }

    return waiter.future;
  }

  @override
  Stream<T> executeStream<T>({required Stream<T> stream}) => executeFutureStream<T>(function: () => stream);

  @override
  Stream<T> executeFutureStream<T>({required FutureOr<Stream<T>> Function() function}) {
    final controller = StreamController<T>();
    _waitingStreamList.add((controller, function));

    if (!_isActive) {
      _isActive = true;
      scheduleMicrotask(_runSemaphone);
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
        } catch (ex) {
          item.$1.completeErrorIfIncomplete(ex);
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
            onError: (x, y) => controller.addError(x, y),
            onDone: () => controller.close(),
          );

          await controller.done.whenComplete(() => subcription.cancel());
        } catch (ex) {
          controller.addError(ex);
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
