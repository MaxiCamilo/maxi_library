import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/factories/thread_managers_factory_avoid.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_communication_method.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_client.dart';

mixin TemplateThreadInicializerDefinerAnonymous on IThreadInitializer {
  Future<IThreadProcessClient> generateAnonymousClient(IThreadCommunicationMethod channel);

  @override
  Future<void> performInitialization(IThreadCommunicationMethod channel) async {
    ThreadManager.generalFactory = const ThreadManagersFactoryAvoid();

    final client = await generateAnonymousClient(channel);
    ThreadManager.instance = client;
  }
}
