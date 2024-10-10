import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/ithread_message.dart';
import 'package:maxi_library/src/threads/messages/task_finished_message.dart';
import 'package:maxi_library/src/threads/messages/task_running_message.dart';
import 'package:maxi_library/src/threads/processors/thread_request_executor.dart';

class MessageExecuteFunctionInThread<T> with IThreadMessage {
  final InvocationParameters parameters;
  final Future<T> Function(InvocationContext) function;
  final int taskId;

  Type get returnType => T;

  const MessageExecuteFunctionInThread({required this.parameters, required this.function, required this.taskId});

  void execute({required ThreadRequestExecutor executor}) {
    executor.messageOutput.add(TaskRunningMessage(taskId: taskId));
    executor.activeTasks.add(this);
    scheduleMicrotask(() {
      function(InvocationContext.fromParametes(thread: executor.manager, parametres: parameters)).then((x) {
        executor.messageOutput.add(TaskFinishedMessage(taskId: taskId, isFailed: false, result: x));
      }).onError((x, trace) {
        executor.messageOutput.add(TaskFinishedMessage(taskId: taskId, isFailed: true, result: x, trace: trace));
      }).whenComplete(() {
        executor.activeTasks.remove(this);
      });
    });
  }
}
