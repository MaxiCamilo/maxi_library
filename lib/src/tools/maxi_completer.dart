import 'dart:async';

import 'package:maxi_library/export_reflectors.dart';

class MaxiCompleter<T> implements Completer<T> {
  final StackTrace instanceStack = StackTrace.current;
  final _realCompleter = Completer<T>();
  final String waiterName;

  Type get expectedType => T;

  @override
  Future<T> get future => _realCompleter.future;

  @override
  bool get isCompleted => _realCompleter.isCompleted;

  MaxiCompleter({this.waiterName = 'Synchronized waiting'});

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
    _realCompleter.completeError(error, newSt);
  }
}
