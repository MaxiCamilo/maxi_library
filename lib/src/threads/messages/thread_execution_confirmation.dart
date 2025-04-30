import 'package:maxi_library/src/threads/interfaces/ithread_message.dart';

class ThreadExecutionConfirmation with IThreadMessage {
  final int newId;

  const ThreadExecutionConfirmation({required this.newId});
}
