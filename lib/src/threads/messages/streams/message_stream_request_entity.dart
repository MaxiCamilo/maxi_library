import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/context_process_thread_messages.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_message.dart';

class MessageStreamRequestEntity<T, R> with IThreadMessage {
  final InvocationParameters parameters;
  final Future<Stream<R>> Function(T, InvocationParameters) function;

  const MessageStreamRequestEntity({required this.parameters, required this.function});

  @override
  Future<void> openMessage({required ContextProcessThreadMessages context}) {
    return context.communicator.executorRequestStream.executeRequestedEntityStream<T>(parameters: parameters, function: function);
  }
}
