import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_communication.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_client.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_entity.dart';
import 'package:maxi_library/src/threads/isolates/abilitys/abylitys_isolate_client_thread_get_sender_entity.dart';
import 'package:maxi_library/src/threads/isolates/abilitys/abylitys_thread_linked_sender.dart';
import 'package:maxi_library/src/threads/templates/template_thread_process_cliente_standar.dart';

class ThreadProcessClienteEntityIsolate<T>
    with IThreadInvoker, IThreadProcess, IThreadProcessClient, TemplateThreadProcessClienteStandar, AbylitysThreadLinkedSender, AbylitysIsolateClientThreadGetSenderEntity, IThreadProcessEntity<T> {
  T _entity;

  @override
  final IThreadCommunication serverCommunicator;

  ThreadProcessClienteEntityIsolate({required T entity, required this.serverCommunicator}) : _entity = entity;

  @override
  T get entity => _entity;

  @override
  Type get typeManager => _entity.runtimeType;

  @override
  set entity(T newItem) => _entity = newItem;
}
