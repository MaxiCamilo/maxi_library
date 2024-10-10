import 'package:maxi_library/src/threads/ithread_message.dart';

class RequestCancellationStreamInThread with IThreadMessage {
  final int streamId;

  const RequestCancellationStreamInThread({required this.streamId});
}
