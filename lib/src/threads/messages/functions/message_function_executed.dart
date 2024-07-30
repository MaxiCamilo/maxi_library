import 'package:maxi_library/src/threads/context_process_thread_messages.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_message.dart';

class MessageFunctionExecuted with IThreadMessage {
  final int idTask;

  const MessageFunctionExecuted({required this.idTask});

  @override
  Future<void> openMessage({required ContextProcessThreadMessages context}) async {
    context.communicator.requestManager.confirmTaskRunning(idTask);
  }
}
