import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_communication.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_client.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_entity.dart';
import 'package:maxi_library/src/threads/isolates/abilitys/abylitys_isolate_client_thread_get_sender_entity.dart';
import 'package:maxi_library/src/threads/isolates/abilitys/abylitys_thread_linked_sender.dart';
import 'package:maxi_library/src/threads/operators_via_messages/thread_comunication_standar.dart';
import 'package:maxi_library/src/threads/templates/template_thread_process_cliente_standar.dart';

class ThreadProcessClienteEntityIsolate<T>
    with IThreadInvoker, IThreadProcess, IThreadProcessClient, TemplateThreadProcessClienteStandar, AbylitysThreadLinkedSender, AbylitysIsolateClientThreadGetSenderEntity, IThreadProcessEntity<T> {
  T _entity;

  @override
  late final IThreadCommunication serverCommunicator;

  @override
  T get entity => _entity;

  @override
  Type get typeManager => _entity.runtimeType;

  @override
  set entity(T newItem) => _entity = newItem;

  ThreadProcessClienteEntityIsolate._({required T entity}) : _entity = entity;

  factory ThreadProcessClienteEntityIsolate.withThreadCommunicator({required T entity, required IThreadCommunication serverCommunicator}) {
    final newProcess = ThreadProcessClienteEntityIsolate._(entity: entity);
    newProcess.serverCommunicator = serverCommunicator;
    return newProcess;
  }

  factory ThreadProcessClienteEntityIsolate.withCommunicationMethod({required T entity, required IThreadCommunicationMethod port}) {
    final newProcess = ThreadProcessClienteEntityIsolate._(entity: entity);

    final newCommunicator = ThreadComunicationStandar(managerThisTread: newProcess, port: port);

    newProcess.serverCommunicator = newCommunicator;

    return newProcess;
  }
}
