import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/fakers/fake_threads.dart';

class FakeThreadFactory with IThreadManagersFactory {
  const FakeThreadFactory();

  @override
  IThreadManager createServer({required List<IThreadInitializer> threadInitializer}) {
    return FakeThreads();
  }
}
