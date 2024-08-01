import 'package:maxi_library/src/threads/interfaces/ithread_invoker.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_magares_factory.dart';

class ThreadManagersFactoryIsolator with IThreadManagersFactory {
  const ThreadManagersFactoryIsolator();

  @override
  IThreadInvoker createServer() {
    // TODO: implement createServer
    throw UnimplementedError();
  }
}
