import 'package:maxi_library/src/threads/ithread_message.dart';

class TaskRunningMessage with IThreadMessage {
  final int taskId;

  const TaskRunningMessage({required this.taskId});
}
