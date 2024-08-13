import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_communication_method.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_entity.dart';

class ThreadInitializerEntity with IThreadInitializer {
  @override
  Future<void> performInitializationInThread(IThreadCommunicationMethod channel) async {
    final process = ThreadManager.getProcess();

    if (process is IThreadProcessEntity) {
      final item = IThreadProcessEntity.getGenericItemFromProcess(process);

      if (item is StartableFunctionality) {
        await item.initialize();
      }
    }
  }
}
