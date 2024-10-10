import 'package:maxi_library/src/threads/ithread_message.dart';

class TaskFinishedMessage with IThreadMessage {
  final int taskId;
  final dynamic result;
  final bool isFailed;
  final StackTrace? trace;

  const TaskFinishedMessage({
    required this.taskId,
    required this.result,
    required this.isFailed,
    this.trace,
  });
}
