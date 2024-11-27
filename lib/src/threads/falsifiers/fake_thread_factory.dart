import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/falsifiers/fake_thread_server.dart';

class FakeThreadFactory with IThreadManagersFactory {
  const FakeThreadFactory();

  @override
  IThreadManager createServer({required List<IThreadInitializer> threadInitializer}) {
    return FakeThreadServer();
  }
}
