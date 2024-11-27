import 'package:maxi_library/src/threads/ithread_message.dart';

class ThreadExecutionConfirmation with IThreadMessage {
  final int newId;

  const ThreadExecutionConfirmation({required this.newId});
}
