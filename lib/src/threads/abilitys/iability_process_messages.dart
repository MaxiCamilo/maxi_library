import 'package:maxi_library/src/threads/ithread_message.dart';

mixin IAbilityProcessMessages {
  Future<void> processMessage(IThreadMessage message);
}
