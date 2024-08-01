import 'package:maxi_library/src/threads/interfaces/ithread_communication_method.dart';

mixin IThreadInitializer {
  Future<void> performInitialization(IThreadCommunicationMethod channel);
}
