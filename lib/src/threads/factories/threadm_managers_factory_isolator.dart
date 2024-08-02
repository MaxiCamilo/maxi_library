import 'package:maxi_library/src/threads/interfaces/ithread_initializer.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_invoker.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_magares_factory.dart';
import 'package:maxi_library/src/threads/isolates/thread_process_server_isolator.dart';

class ThreadManagersFactoryIsolator with IThreadManagersFactory {
  const ThreadManagersFactoryIsolator();

  @override
  IThreadInvoker createServer({required List<IThreadInitializer> threadInitializer}) => ThreadProcessServerIsolator(threadInitializer: threadInitializer);
}
