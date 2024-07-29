import 'package:maxi_library/src/threads/operators/ithread_message.dart';

mixin IAbilityReceiveThreadMessages {
  bool get isActive;

  Stream<IThreadMessage> get receivedMessage;

  Stream get receivedUnknownMaterial;

  Future<void> closerConnection();
}
