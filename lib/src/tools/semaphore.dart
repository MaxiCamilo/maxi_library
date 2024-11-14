import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class Semaphore {
  final _waitingList = <(Completer, Future Function())>[];
  final _waitingStreamList = <(StreamController, Future<Stream> Function())>[];

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

  Stream<T> executeStream<T>({required Future<Stream<T>> Function() function}) {
    final controller = StreamController<T>();
    _waitingStreamList.add((controller, function));

    if (!_isActive) {
      _isActive = true;
      scheduleMicrotask(_runSemaphone);
    }

    return controller.stream;
  }

  Future<T?> executeIfStopped<T>({required Future<T> Function() function}) async {
    if (!_isActive) {
      return await execute(function: function);
    } else {
      return null;
    }
  }

  void cancel() {
    _waitingList.iterar((x) => x.$1.completeErrorIfIncomplete(NegativeResult(identifier: NegativeResultCodes.functionalityCancelled, message: tr('The task was canceled'))));
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
}
