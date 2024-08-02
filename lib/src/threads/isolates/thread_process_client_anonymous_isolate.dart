import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_communication.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_communication_method.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_client.dart';
import 'package:maxi_library/src/threads/isolates/abilitys/abylitys_isolate_client_thread_get_sender_entity.dart';
import 'package:maxi_library/src/threads/isolates/abilitys/abylitys_thread_linked_sender.dart';
import 'package:maxi_library/src/threads/operators_via_messages/thread_comunication_standar.dart';
import 'package:maxi_library/src/threads/templates/template_thread_process_cliente_standar.dart';

class ThreadProcessClientAnonymousIsolate with IThreadInvoker, IThreadProcess, IThreadProcessClient, TemplateThreadProcessClienteStandar, AbylitysThreadLinkedSender, AbylitysIsolateClientThreadGetSenderEntity {
  @override
  late final IThreadCommunication serverCommunicator;

  ThreadProcessClientAnonymousIsolate._();

  factory ThreadProcessClientAnonymousIsolate.withThreadCommunicator({required IThreadCommunication serverCommunicator}) {
    final newProcess = ThreadProcessClientAnonymousIsolate._();
    newProcess.serverCommunicator = serverCommunicator;
    return newProcess;
  }

  factory ThreadProcessClientAnonymousIsolate.withCommunicationMethod({required IThreadCommunicationMethod port}) {
    final newProcess = ThreadProcessClientAnonymousIsolate._();

    final newCommunicator = ThreadComunicationStandar(managerThisTread: newProcess, port: port);

    newProcess.serverCommunicator = newCommunicator;

    return newProcess;
  }
}
