import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/ithread_message.dart';
import 'package:maxi_library/src/threads/processors/thread_request_executor.dart';
import 'package:maxi_library/src/threads/processors/thread_stream_instance.dart';

class MessageExecuteEntityStreamInThread<E, R> with IThreadMessage {
  final InvocationParameters parameters;
  final Future<Stream<R>> Function(E, InvocationContext) function;
  final int taskId;
  final bool cancelOnError;

  Type get returnType => R;
  Type get entityType => E;

  const MessageExecuteEntityStreamInThread({required this.parameters, required this.function, required this.taskId, required this.cancelOnError});

  ThreadStreamInstance<R> createInstance({required ThreadRequestExecutor executor}) {
    return ThreadStreamInstance.fromEntity<E, R>(executor: executor, message: this);
  }
}
