import 'package:maxi_library/src/threads/ithread_message.dart';

mixin IAbilitySendThreadMessages {
  Future<void> sendMessage(IThreadMessage message);
  Future<void> sendUnkownMaterial(dynamic any);
}
