import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/context_process_thread_messages.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_message.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_server.dart';

class MessageStreamRequestAnonymous<R> with IThreadMessage {
  final InvocationParameters parameters;
  final Future<Stream<R>> Function(InvocationParameters) function;

  const MessageStreamRequestAnonymous({required this.parameters, required this.function});

  @override
  Future<void> openMessage({required ContextProcessThreadMessages context}) {
    if (context.managerThisThread is IThreadProcessServer) {
      //THIS MUST RETURN the new ID of the stream
      throw UnimplementedError('[MAXI] ¡Hey, this is beguin used!');
    } else {
      return context.communicator.executorRequestStream.executeRequestedStream(parameters: parameters, function: function);
    }
  }
}
