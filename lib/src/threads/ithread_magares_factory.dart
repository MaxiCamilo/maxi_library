import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/ithread_communication.dart';
import 'package:maxi_library/src/threads/ithread_invoker.dart';

mixin IThreadManagersFactory {
  IThreadInvoker createServer();

  Future<IThreadCommunication> createThreadAnonymous({required IThreadInvoker connectorServer});

  Future<IThreadCommunication> createEntityThread<T>({required IThreadInvoker connectorServer, T entity});
}
