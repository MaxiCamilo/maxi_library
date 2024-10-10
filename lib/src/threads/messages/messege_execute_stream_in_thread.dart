import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/ithread_message.dart';
import 'package:maxi_library/src/threads/processors/thread_request_executor.dart';
import 'package:maxi_library/src/threads/processors/thread_stream_instance.dart';

class MessegeExecuteStreamInThread<T> with IThreadMessage {
  final InvocationParameters parameters;
  final Future<Stream<T>> Function(InvocationContext) function;
  final int taskId;
  final bool cancelOnError;

  Type get returnType => T;

  const MessegeExecuteStreamInThread({required this.parameters, required this.function, required this.taskId, required this.cancelOnError});

  ThreadStreamInstance<T> createInstance({required ThreadRequestExecutor executor}) {
    return ThreadStreamInstance<T>.fromAnonymous(executor: executor, message: this);
  }
}
