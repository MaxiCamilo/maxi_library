import 'package:maxi_library/src/threads/context_process_thread_messages.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_message.dart';

class MessageStreamItem with IThreadMessage {
  final int idStrem;
  final dynamic item;

  const MessageStreamItem({required this.item, required this.idStrem});

  @override
  Future<void> openMessage({required ContextProcessThreadMessages context}) async {
    context.communicator.streamManager.confirmStreamItem(idStrem, item);
  }
}
