import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/isolates/thread_isolator_server.dart';

class IsolatedThreadFactory with IThreadManagersFactory {
  const IsolatedThreadFactory();

  @override
  IThreadManager createServer({required List<IThreadInitializer> threadInitializer}) {
    final newServer = ThreadIsolatorServer();

    threadInitializer.iterar((x) => newServer.addThreadInitializer(initializer: x));

    return newServer;
  }
}
