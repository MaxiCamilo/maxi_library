import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';

class CustomStreamSink<T> implements StreamSink<T> {
  final FutureOr Function(T) onNewItem;
  final void Function(Object error, StackTrace? stackTrace)? onNewError;
  final Future waitDone;
  final Function? onDone;

  bool _isActive = true;

  final _waiter = MaxiCompleter();
  late final Future _waitDoneFuture;

  bool get isActive => _isActive;

  CustomStreamSink({required this.onNewItem, this.onNewError, required this.waitDone, this.onDone}) {
    _waitDoneFuture = waitDone.whenComplete(() {
      close();
    });
  }

  @override
  void add(T event) {
    maxiScheduleMicrotask(() async {
      await continueOtherFutures();
      await onNewItem(event);
      await continueOtherFutures();
    }).then((error) {
      if (error != null) {
        log('[CustomStreamSink] Error sent: ${error.$1}\n${error.$2}');
      }
    });
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    if (onNewError == null) {
      log('[CustomStreamSink] $error \n$stackTrace');
    } else {
      onNewError!(error, stackTrace);
    }
  }

  void addIfActive(T event) {
    if (isActive) {
      add(event);
    }
  }

  void addErrorIfActive(Object error, [StackTrace? stackTrace]) {
    if (isActive) {
      addError(error, stackTrace);
    }
  }

  @override
  Future addStream(Stream<T> stream) async {
    final waiter = MaxiCompleter<void>();

    late final StreamSubscription<T> subscription;
    subscription = stream.listen(
      (x) => add(x),
      onError: (x, y) => addError(x, y),
      onDone: () => waiter.complete(),
    );

    final future = done.whenComplete(() => subscription.cancel());

    await waiter.future;
    future.ignore();
  }

  @override
  Future close() async {
    if (_isActive) {
      _waiter.completeIfIncomplete();
      _waitDoneFuture.ignore();
      _isActive = false;
      if (onDone != null) {
        onDone!();
      }
    }
  }

  @override
  Future get done => _waiter.future;
}
