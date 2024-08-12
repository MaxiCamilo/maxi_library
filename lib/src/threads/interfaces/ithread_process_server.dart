import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_communication.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process.dart';

mixin IThreadProcessServer on IThreadInvoker, IThreadProcess {
  List<IThreadCommunication> get listAnonymousCommunicatios;

  Future<IThreadCommunication> createAnonymousThread({required String name, required List<IThreadInitializer> initializers});
  Future<IThreadCommunication> createEntitysManager<T>({required T item, required List<IThreadInitializer> initializers});
}
