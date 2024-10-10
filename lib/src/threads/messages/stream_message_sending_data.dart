import 'package:maxi_library/src/threads/ithread_message.dart';

enum StreamMessageSendingDataType { newData, errorData, finished }

class StreamMessageSendingData with IThreadMessage {
  final int taskId;
  final StreamMessageSendingDataType type;
  final dynamic content;
  final StackTrace? trace;

  const StreamMessageSendingData({required this.taskId, required this.type, required this.content, this.trace});
}
