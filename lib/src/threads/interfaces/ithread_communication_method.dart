import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/abilitys/iability_receive_trhead_messages.dart';
import 'package:maxi_library/src/threads/abilitys/iability_send_thread_messages.dart';

mixin IThreadCommunicationMethod {
  bool get isActive;

  IAbilitySendThreadMessages get sender;
  IAbilityReceiveThreadMessages get receiver;

  Future<void> closeCommunication() async {
    containErrorLog(
      detail: tr('[IThreadCommunicationMethod] FAILED! Could not close in the sender'),
      function: () async => await sender.closerConnection(),
    );

    containErrorLog(
      detail: tr('[IThreadCommunicationMethod] FAILED! Could not close in the receiver'),
      function: () async => await receiver.closerConnection(),
    );
  }
}
