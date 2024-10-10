import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/ithread_message.dart';
import 'package:maxi_library/src/threads/messages/task_finished_message.dart';
import 'package:maxi_library/src/threads/messages/task_running_message.dart';
import 'package:maxi_library/src/threads/processors/thread_request_executor.dart';

class MessageExecuteEntityFunctionInThread<E, R> with IThreadMessage {
  final InvocationParameters parameters;
  final Future<R> Function(E, InvocationContext) function;
  final int taskId;

  Type get returnType => R;
  Type get entityType => E;

  const MessageExecuteEntityFunctionInThread({required this.parameters, required this.function, required this.taskId});

  void execute({required ThreadRequestExecutor executor}) {
    executor.messageOutput.add(TaskRunningMessage(taskId: taskId));
    executor.activeTasks.add(this);
    scheduleMicrotask(() {
      _getEntityFirst(executor: executor).then((x) {
        executor.messageOutput.add(TaskFinishedMessage(taskId: taskId, isFailed: false, result: x));
      }).onError((x, trace) {
        executor.messageOutput.add(TaskFinishedMessage(taskId: taskId, isFailed: true, result: x, trace: trace));
      }).whenComplete(() {
        executor.activeTasks.remove(this);
      });
    });
  }

  Future<R> _getEntityFirst({required ThreadRequestExecutor executor}) {
    final entity = executor.manager.entity;
    if (entity == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: tr('The function requires that the thread be assigned an entity of type %1, but there is no entity assigned', [E]),
      );
    }

    if (entity is E) {
      return function(entity, InvocationContext.fromParametes(thread: executor.manager, parametres: parameters));
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: tr('The function requires that the thread be assigned an entity of type %1, but the thread entity is of type %2', [E, entity.runtimeType]),
      );
    }
  }
}
