import 'package:maxi_library/src/threads/context_process_thread_messages.dart';
import 'package:maxi_library/src/threads/operators/ithread_message.dart';

class MessageFunctionFinalize with IThreadMessage {
  final int idTask;
  final bool isCorrect;
  final dynamic content;

  const MessageFunctionFinalize({required this.idTask, required this.isCorrect, required this.content});

  @override
  Future<void> openMessage({required ContextProcessThreadMessages context}) async {
    if (isCorrect) {
      context.communicator.requestManager.confirmTaskCompletion(idTask, content);
    } else {
      context.communicator.requestManager.confirmTaskFailure(idTask, content);
    }
  }
}
