import 'package:maxi_library/src/threads/interfaces/ithread_message.dart';

mixin IAbilityProcessMessages {
  Future<void> processMessage(IThreadMessage message);
}
