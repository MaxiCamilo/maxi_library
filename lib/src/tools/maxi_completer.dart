import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/export_reflectors.dart';

class MaxiCompleter<T> implements Completer<T> {
  final StackTrace instanceStack;
  final _realCompleter = Completer<T>();
  final String waiterName;
  final List<MaxiFuture<T>> _futureList = [];

  bool get hasListener => _futureList.isNotEmpty && _futureList.any((x) => x.wasAccessed);
  bool get allInactive => _futureList.isEmpty || _realCompleter.isCompleted || _futureList.every((x) => x.wasIgnored);

  Type get expectedType => T;

  void Function()? onNoOneListen;

  @override
  MaxiFuture<T> get future {
    final future = MaxiFuture<T>(_realCompleter.future, onIgnore: _onFutureIgnored, onComplete: _onFutureCompleted);
    _futureList.add(future);

    return future;
  }

  void _onFutureIgnored(MaxiFuture<T> future) {
    _futureList.remove(future);
    if (onNoOneListen != null && _futureList.isEmpty) {
      onNoOneListen!();
    }
  }

  @override
  bool get isCompleted => _realCompleter.isCompleted;

  MaxiCompleter({
    this.waiterName = 'Synchronized waiting',
    this.onNoOneListen,
    StackTrace? stack,
  }) : instanceStack = stack ?? StackTrace.current;

  factory MaxiCompleter.fromFuture(FutureOr<T> Function() function) {
    final newCompleter = MaxiCompleter<T>();

    maxiScheduleMicrotask(() async {
      try {
        final result = await function();
        newCompleter.completeIfIncomplete(result);
      } catch (ex, st) {
        newCompleter.completeErrorIfIncomplete(ex, st);
      }
    });

    return newCompleter;
  }

  @override
  void complete([FutureOr? value]) {
    _futureList.clear();
    if (value == null) {
      _realCompleter.complete();
    } else if (value is FutureOr<T>) {
      _realCompleter.complete(value);
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: Oration(message: 'The Waiter needs a %1 result to be completed', textParts: [T.toString()]),
      );
    }
  }

  @override
  void completeError(Object error, [StackTrace? stackTrace]) {
    stackTrace ??= StackTrace.current;

    final newSt = StackTrace.fromString('${stackTrace.toString()}\n-------------------------------------- $waiterName --------------------------------------\n${instanceStack.toString()}');
    //print(newSt.toString());

    if (hasListener) {
      _realCompleter.completeError(error, newSt);
    } else {
      log('Ignorated error: $error');
      log(newSt.toString());
    }

    _futureList.clear();
  }

  void _onFutureCompleted(MaxiFuture<T> future) {
    _futureList.remove(future);
  }
}
