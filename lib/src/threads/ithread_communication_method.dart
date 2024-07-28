import 'package:maxi_library/src/threads/abilitys/iability_receive_trhead_messages.dart';
import 'package:maxi_library/src/threads/abilitys/iability_send_thread_messages.dart';

mixin IThreadCommunicationMethod {
  IAbilitySendThreadMessages get sender;
  IAbilityReceiveThreadMessages get receiver;

}
