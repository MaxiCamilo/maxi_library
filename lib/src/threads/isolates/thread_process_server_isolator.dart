import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/initializer/thread_initializer_entity.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_communication.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_server.dart';
import 'package:maxi_library/src/threads/isolates/abilitys/abylitys_thread_linked_sender.dart';
import 'package:maxi_library/src/threads/isolates/inicializers/thread_inicializer_define_anonymous_isolator.dart';
import 'package:maxi_library/src/threads/isolates/inicializers/thread_inicializer_define_entity.dart';
import 'package:maxi_library/src/threads/isolates/isolate_initializer.dart';
import 'package:maxi_library/src/threads/isolates/thread_communication_method_isolator.dart';
import 'package:maxi_library/src/threads/operators_via_messages/thread_comunication_standar.dart';
import 'package:maxi_library/src/threads/templates/template_thread_process_server.dart';

class ThreadProcessServerIsolator with IThreadInvoker, IThreadProcess, IThreadProcessServer, TemplateThreadProcessServer, AbylitysThreadLinkedSender {
  @override
  final List<IThreadInitializer> threadInitializer;


  ThreadProcessServerIsolator({this.threadInitializer = const []});

  @override
  Future<IThreadCommunication> createAnonymousManagerAccordingImplementation({required String name, required List<IThreadInitializer> initializers}) async {
    final initializersPrepared = [
      ThreadInicializerDefineAnonymousIsolator(),
      ...threadInitializer,
      ...initializers,
    ];

    final channel = await IsolateInitializer(initializers: initializersPrepared).mountIsolate(name);
    return ThreadComunicationStandar(managerThisTread: this, port: ThreadCommunicationMethodIsolator(channel: channel));
  }

  @override
  Future<IThreadCommunication> createEntitysManagerAccordingImplementation<T>({required T item, required List<IThreadInitializer> initializers}) async {
    final initializersPrepared = [
      ThreadInicializerDefineEntity<T>(entity: item),
      ...threadInitializer,
      ...initializers,
      ThreadInitializerEntity(),
    ];

    late final String name;
    if (item is ThreadService) {
      name = item.serviceName;
    } else {
      name = item.runtimeType.toString();
    }

    final channel = await IsolateInitializer(initializers: initializersPrepared).mountIsolate(name);
    return ThreadComunicationStandar(managerThisTread: this, port: ThreadCommunicationMethodIsolator(channel: channel));
  }
}
