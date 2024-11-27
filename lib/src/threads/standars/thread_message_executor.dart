import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/ithread_message.dart';
import 'package:maxi_library/src/threads/messages/thread_execute_function.dart';
import 'package:maxi_library/src/threads/messages/thread_execution_confirmation.dart';
import 'package:maxi_library/src/threads/messages/thread_execution_finished.dart';

class ThreadMessageExecutor {
  final IThreadManager thread;
  final IThreadInvoker sender;

  final StreamSink<IThreadMessage> senderMessage;

  final activeFunctions = <int, Completer>{};

  int _lastIDTask = 1;

  bool _isActive = true;

  ThreadMessageExecutor({required this.thread, required this.sender, required this.senderMessage});

  Future<void> executeExternalFunction(ThreadExecuteFunction message) async {
    final id = _lastIDTask;
    _lastIDTask += 1;

    final completer = message.makeCompleter();
    activeFunctions[id] = completer;

    senderMessage.add(ThreadExecutionConfirmation(newId: id));

    try {
      late final dynamic result;
      if (message.function is Future Function(InvocationContext)) {
        final future = (message.function as Future Function(InvocationContext))(InvocationContext.fromParametes(thread: thread, applicant: sender, parametres: message.parameters));
        result = await Future.any([future, completer.future]);

        future.ignore();
      } else {
        result = message.function(InvocationContext.fromParametes(thread: thread, applicant: sender, parametres: message.parameters));
      }

      completer.completeIfIncomplete(result);

      if (_isActive) {
        senderMessage.add(ThreadExecutionFinished(identifier: id, isCorrect: true, result: result));
      }
    } catch (ex, st) {
      completer.completeErrorIfIncomplete(ex, st);
      if (_isActive) {
        senderMessage.add(ThreadExecutionFinished(identifier: id, isCorrect: false, result: ex, stackTrace: st));
      }
    } finally {
      activeFunctions.remove(id);
    }
  }

  void cancelFunction({required int id}) {
    final instance = activeFunctions[id];
    if (instance != null) {
      instance.completeErrorIfIncomplete(NegativeResult(identifier: NegativeResultCodes.functionalityCancelled, message: tr('The function was cancelled')));
    } else {
      log('[ThreadMessageExecutor] Function $id is not exists');
    }
  }

  void close() {
    if (!_isActive) {
      return;
    }

    _isActive = false;
    for (final item in activeFunctions.values) {
      item.completeErrorIfIncomplete(NegativeResult(identifier: NegativeResultCodes.functionalityCancelled, message: tr('The function was cancelled')));
    }

    activeFunctions.clear();
  }
}
