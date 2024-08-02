import 'package:maxi_library/src/threads/interfaces/ithread_communication_method.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_initializer.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_client.dart';
import 'package:maxi_library/src/threads/isolates/thread_process_client_anonymous_isolate.dart';
import 'package:maxi_library/src/threads/templates/template_thread_inicializer_define_anonymous.dart';

class ThreadInicializerDefineAnonymousIsolator with IThreadInitializer, TemplateThreadInicializerDefinerAnonymous {
  const ThreadInicializerDefineAnonymousIsolator();

  @override
  Future<IThreadProcessClient> generateAnonymousClient(IThreadCommunicationMethod channel) async {
    return ThreadProcessClientAnonymousIsolate.withCommunicationMethod(port: channel);
  }
}
