import 'package:maxi_library/src/threads/interfaces/ithread_message.dart';

mixin IAbilitySendThreadMessages {
  bool get isActive;

  Future<void> sendMessage(IThreadMessage message);
  Future<void> sendUnkownMaterial(dynamic any);

  Future<void> closerConnection();
}
