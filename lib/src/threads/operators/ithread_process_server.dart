import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/operators/ithread_communication.dart';
import 'package:maxi_library/src/threads/operators/ithread_initializer.dart';
import 'package:maxi_library/src/threads/operators/ithread_process.dart';

mixin IThreadProcessServer on IThreadInvoker, IThreadProcess {
  Future<IThreadCommunication> mountAnonymousThread({required String name, required List<IThreadInitializer> initializers});
  Future<IThreadCommunication> mounthEntitysManager<T>({required T item, required List<IThreadInitializer> initializers});
}
