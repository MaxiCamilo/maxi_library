import 'package:maxi_library/src/threads/context_process_thread_messages.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_message.dart';

class MessageStreamFinalize with IThreadMessage {
  final int idStream;

  const MessageStreamFinalize({required this.idStream});

  @override
  Future<void> openMessage({required ContextProcessThreadMessages context}) async {
    context.communicator.streamManager.confirmStreamEnd(idStream);
  }
}