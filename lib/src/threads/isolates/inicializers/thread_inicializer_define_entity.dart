import 'package:maxi_library/src/threads/interfaces/ithread_communication_method.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_initializer.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_entity.dart';
import 'package:maxi_library/src/threads/isolates/thread_process_cliente_entity_isolate.dart';
import 'package:maxi_library/src/threads/templates/templete_thread_inicializer_define_entity.dart';

class ThreadInicializerDefineEntity<E> with IThreadInitializer, TempletaThreadInicializerDefineEntity<E> {
  @override
  final E entity;

  const ThreadInicializerDefineEntity({required this.entity});

  @override
  Future<IThreadProcessEntity<E>> generateEntityClient(IThreadCommunicationMethod channel) async {
    return ThreadProcessClienteEntityIsolate<E>.withCommunicationMethod(port: channel, entity: entity);
  }
}
