import 'package:maxi_library/src/threads/ithread_message.dart';

mixin IAbilityReceiveThreadMessages {
  Stream<IThreadMessage> get receivedMessage;

  Stream get receivedUnknownMaterial;

  
}
