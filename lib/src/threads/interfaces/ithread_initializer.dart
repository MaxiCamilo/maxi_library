import 'package:maxi_library/src/threads/interfaces/ithread_manager.dart';

mixin IThreadInitializer {
  Future<void> performInitializationInThread(IThreadManager channel);
}
