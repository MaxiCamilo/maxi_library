import 'package:maxi_library/src/threads/context_process_thread_messages.dart';
import 'package:maxi_library/src/threads/operators/ithread_message.dart';

class MessageNotificationThreadClosure with IThreadMessage {
  @override
  Future<void> openMessage({required ContextProcessThreadMessages context}) async {
    context.communicator.reactClosingThread();
  }
}
