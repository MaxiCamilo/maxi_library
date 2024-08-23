import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/factories/thread_managers_factory_avoid.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_entity.dart';

mixin TempletaThreadInicializerDefineEntity<T> on IThreadInitializer {
  T get entity;

  Future<IThreadProcessEntity<T>> generateEntityClient(IThreadCommunicationMethod channel);

  @override
  Future<void> performInitializationInThread(IThreadCommunicationMethod channel) async {
    ThreadManager.generalFactory = const ThreadManagersFactoryAvoid();

    final client = await generateEntityClient(channel);
    ThreadManager.instance = client;
  }
}
