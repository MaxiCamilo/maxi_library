import 'package:maxi_library/src/threads/ithread_manager.dart';

mixin IThreadInitializer {
  Future<void> performInitializationInThread(IThreadManager channel);
}
