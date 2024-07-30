import 'package:maxi_library/src/threads/context_process_thread_messages.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_message.dart';

class MessageStreamExecute with IThreadMessage {
  final int idStram;
  final bool isCorrect;
  final dynamic error;

  const MessageStreamExecute({required this.idStram, required this.error, required this.isCorrect});

  @override
  Future<void> openMessage({required ContextProcessThreadMessages context}) async {
    if (isCorrect) {
      context.communicator.streamManager.confirmStreamRunning(idStram);
    } else {
      context.communicator.streamManager.confirmStreamFailure(idStram, error);
    }
  }
}
