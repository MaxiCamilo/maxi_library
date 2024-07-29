import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/operators/ithread_communication.dart';
import 'package:maxi_library/src/threads/operators/ithread_initializer.dart';
import 'package:maxi_library/src/threads/operators/ithread_invoker.dart';

mixin IThreadManagersFactory {
  IThreadInvoker createServer();

  Future<IThreadCommunication> createThreadAnonymous({required IThreadInvoker connectorServer, required List<IThreadInitializer> initializers});

  Future<IThreadCommunication> createEntityThread<T>({required IThreadInvoker connectorServer, T entity, required List<IThreadInitializer> initializers});
}
