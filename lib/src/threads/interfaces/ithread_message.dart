import 'package:maxi_library/src/threads/context_process_thread_messages.dart';

mixin IThreadMessage {
  Future<void> openMessage({required ContextProcessThreadMessages context});
}
