import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class QueuingSemaphore<T> {
  final FutureOr<T> Function() reservedFunction;
  final _semaphore = Semaphore();

  Completer<T>? _waiter;
  Completer? _doneCompleter;
  Completer<T>? _doneWaitingExecution;
  bool _avoidReexecution = false;

  bool get isActive => _semaphore.isActive;
  Future get done => _doneCompleter == null ? (_doneCompleter = MaxiCompleter()).future : _doneCompleter!.future;

  QueuingSemaphore({required this.reservedFunction});

  Future<T> execute() {
    _waiter ??= MaxiCompleter<T>();
    _doneCompleter ??= MaxiCompleter();

    if (!isActive) {
      _semaphore.execute(function: _executeFunction);
    }
    return _waiter!.future;
  }

  void executeIfNotActive() async {
    if (!isActive) {
      execute();
    }
  }

  Future<T> reExecute() async {
    if (!isActive) {
      return execute();
    }

    if (_avoidReexecution) {
      await _doneWaitingExecution!.future;
      return await execute();
    }

    _avoidReexecution = true;
    _doneWaitingExecution ??= MaxiCompleter<T>();
    await done;

    try {
      final result = await execute();
      _doneWaitingExecution?.completeIfIncomplete();
      _doneWaitingExecution = null;

      return result;
    } catch (ex, st) {
      _doneWaitingExecution?.completeErrorIfIncomplete(ex, st);
      _doneWaitingExecution = null;
      rethrow;
    } finally {
      _avoidReexecution = false;
    }
  }

  Future<void> _executeFunction() async {
    _waiter ??= MaxiCompleter<T>();
    _doneCompleter ??= MaxiCompleter();

    try {
      final result = await reservedFunction();
      _waiter?.completeIfIncomplete(result);
      _waiter = null;
    } catch (x, y) {
      _waiter?.completeErrorIfIncomplete(x, y);
      _waiter = null;
    } finally {
      _doneCompleter?.completeIfIncomplete();
      _doneCompleter = null;
    }
  }
}
