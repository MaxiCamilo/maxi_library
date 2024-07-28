import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/abilitys/iability_send_thread_messages.dart';
import 'package:maxi_library/src/threads/ithread_message.dart';
import 'package:maxi_library/src/threads/ithread_process.dart';
import 'package:maxi_library/src/threads/ithread_request_manager.dart';
import 'package:maxi_library/src/threads/messages/functions/message_function_request_anonymus.dart';
import 'package:maxi_library/src/threads/messages/functions/message_function_request_entity.dart';

class ThreadRequestManagerStandar with IThreadRequestManager {
  final IAbilitySendThreadMessages sender;
  final IThreadProcess manager;

  final _pendingTask = <int, Completer>{};
  final _synchronizerRequests = Semaphore();

  int _lastId = 0;

  Completer<int>? _identifierWaiter;

  ThreadRequestManagerStandar({required this.sender, required this.manager});

  @override
  Future<R> callEntityFunction<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(T, InvocationParameters) function}) async {
    return await _synchronizerRequests.execute(
      function: () async => await _sendSolicitud<R>(
        MessageFunctionRequestEntity<T, R>(
          parameters: parameters,
          function: function,
        ),
      ),
    );
  }

  @override
  Future<R> callFunctionAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationParameters) function}) async {
    return await _synchronizerRequests.execute(
      function: () async => await _sendSolicitud<R>(
        MessageFunctionRequestAnonymus<R>(
          parameters: parameters,
          function: function,
        ),
      ),
    );
  }

  Future<Future<R>> _sendSolicitud<R>(IThreadMessage message) async {
    _identifierWaiter = Completer<int>();
    await sender.sendMessage(message);

    final receivedId = await _identifierWaiter!.future;
    if (_lastId != receivedId) {
      log('[ThreadRequestManagerStandar] WARNING!: The last id is "$_lastId", but id $_identifierWaiter was received');
    }

    _lastId = receivedId + 1;
    final resultWaiter = Completer<R>();
    _pendingTask[receivedId] = resultWaiter;

    return resultWaiter.future;
  }

  @override
  void confirmTaskCompletion(int idTask, result) {
    final pending = _getResultWaiter(idTask);
    if (pending == null) {
      return;
    }

    try {
      pending.complete(result);
    } catch (ex) {
      pending.completeError(NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: 'The result of the task of type "${result.runtimeType}" was not accepted',
      ));
    }
  }

  @override
  void confirmTaskFailure(int idTask, failure) {
    final pending = _getResultWaiter(idTask);
    if (pending == null) {
      return;
    }

    pending.completeError(failure);
  }

  Completer? _getResultWaiter(int idTask) {
    final pending = _pendingTask[idTask];
    if (pending == null) {
      log('[ThreadRequestManagerStandar] WARNING!: The completion of task number $idTask was not expected');
      return null;
    } else if (pending.isCompleted) {
      log('[ThreadRequestManagerStandar] WARNING!: The task number $idTask is already finished, but its completion has been sent');
      return null;
    }

    return pending;
  }

  @override
  void confirmTaskRunning(int idTask) {
    if (_identifierWaiter == null || _identifierWaiter!.isCompleted) {
      log('[ThreadRequestManagerStandar] WARNING!: The start of task number $idTask was not expected');
      return;
    }

    _identifierWaiter!.complete(idTask);
  }
}
