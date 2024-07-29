import 'package:maxi_library/src/threads/context_process_thread_messages.dart';
import 'package:maxi_library/src/threads/operators/ithread_message.dart';

class MessageStreamError with IThreadMessage {
  final int idStream;
  final dynamic error;

  const MessageStreamError({required this.error, required this.idStream});

  @override
  Future<void> openMessage({required ContextProcessThreadMessages context}) async {
    context.communicator.streamManager.confirmStreamError(idStream, error);
  }
}
