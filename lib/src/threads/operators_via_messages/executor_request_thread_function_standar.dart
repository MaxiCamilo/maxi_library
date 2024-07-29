import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/src/prefixes/functionality_prefixes.dart';
import 'package:maxi_library/src/threads/abilitys/iability_send_thread_messages.dart';
import 'package:maxi_library/src/threads/operators/iexecutor_requested_thread_functions.dart';
import 'package:maxi_library/src/threads/invocation_parameters.dart';
import 'package:maxi_library/src/threads/operators/ithread_process_entity.dart';
import 'package:maxi_library/src/threads/operators/ithread_message.dart';
import 'package:maxi_library/src/threads/operators/ithread_process.dart';
import 'package:maxi_library/src/threads/messages/functions/message_function_executed.dart';
import 'package:maxi_library/src/threads/messages/functions/message_function_finalize.dart';

class ExecutorRequestThreadFunctionMessages with IExecutorRequestedThreadFunctions {
  final IAbilitySendThreadMessages sender;
  final IThreadProcess manager;

  List<int> idsTask = [];

  int _lastIdTask = 0;
  bool _isActive = true;

  ExecutorRequestThreadFunctionMessages({required this.sender, required this.manager});

  @override
  Future<void> executeRequestedFunction({required InvocationParameters parameters, required Function(InvocationParameters) function}) async {
    final newId = _lastIdTask;
    _lastIdTask += 1;

    idsTask.add(newId);

    scheduleMicrotask(() => _executeRequestAnonymous(newId, parameters, function));

    await _sendReplyMessage(
      'Sending confirmation of running task N° $newId (anonymous)',
      MessageFunctionExecuted(idTask: newId),
    );
  }

  @override
  Future<void> executeRequestedEntityFunction<T>({required InvocationParameters parameters, required Function(T, InvocationParameters) function}) async {
    final newId = _lastIdTask;
    _lastIdTask += 1;

    idsTask.add(newId);

    scheduleMicrotask(() => _executeRequestEntity<T>(newId, parameters, function));

    await _sendReplyMessage(
      'Sending confirmation of running task N° $newId (entity $T)',
      MessageFunctionExecuted(idTask: newId),
    );
  }

  Future<void> _executeRequestAnonymous(int idTask, InvocationParameters parameters, Function(InvocationParameters p1) function) async {
    try {
      final result = await function(parameters);
      await _sendReplyMessage(
        'Sending positive task result N° $idTask ',
        MessageFunctionFinalize(idTask: idTask, isCorrect: true, content: result),
      );
    } catch (ex) {
      await _sendReplyMessage('Sending negative task result N° $idTask (anonymous)', MessageFunctionFinalize(idTask: idTask, isCorrect: false, content: ex));
    } finally {
      idsTask.remove(idTask);
    }
  }

  Future<void> _sendReplyMessage(String detail, IThreadMessage messege) async {
    if (!_isActive) {
      log('[ExecutorRequestThreadFunctionMessages] WARNING!: The executor is inactive, but an attempt was made to send a message ("$detail")');
      return;
    }

    await containErrorLogAsync(
      detail: () => detail,
      function: () => sender.sendMessage(messege),
    );
  }

  Future<void> _executeRequestEntity<T>(int idTask, InvocationParameters parameters, Function(T, InvocationParameters) function) async {
    try {
      final entity = IThreadProcessEntity.getItemFromProcess<T>(manager);
      final result = await function(entity, parameters);
      await _sendReplyMessage(
        'Sending positive task result N° $idTask ',
        MessageFunctionFinalize(idTask: idTask, isCorrect: true, content: result),
      );
    } catch (ex) {
      await _sendReplyMessage(
        'Sending negative task result N° $idTask (anonymous)',
        MessageFunctionFinalize(idTask: idTask, isCorrect: false, content: ex),
      );
    } finally {
      idsTask.remove(idTask);
    }
  }

  @override
  void reactClosingThread() {
    _isActive = false;
  }
}
