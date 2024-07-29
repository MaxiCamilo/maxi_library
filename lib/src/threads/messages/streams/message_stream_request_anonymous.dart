import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/context_process_thread_messages.dart';
import 'package:maxi_library/src/threads/operators/ithread_message.dart';

class MessageStreamRequestAnonymous<R> with IThreadMessage {
  final InvocationParameters parameters;
  final Future<Stream<R>> Function(InvocationParameters) function;

  const MessageStreamRequestAnonymous({required this.parameters, required this.function});

  @override
  Future<void> openMessage({required ContextProcessThreadMessages context}) {
    return context.communicator.executorRequestStream.executeRequestedStream(parameters: parameters, function: function);
  }
}
