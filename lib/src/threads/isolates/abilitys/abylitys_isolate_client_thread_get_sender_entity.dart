import 'dart:isolate';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_communication.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_client.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_server.dart';
import 'package:maxi_library/src/threads/isolates/abilitys/abylitys_thread_linked_sender.dart';
import 'package:maxi_library/src/threads/isolates/channel_isolates.dart';
import 'package:maxi_library/src/threads/isolates/thread_communication_method_isolator.dart';
import 'package:maxi_library/src/threads/operators_via_messages/thread_comunication_standar.dart';
import 'package:maxi_library/src/threads/templates/template_thread_process_cliente_standar.dart';

mixin AbylitysIsolateClientThreadGetSenderEntity on IThreadInvoker, IThreadProcess, IThreadProcessClient, TemplateThreadProcessClienteStandar {
  @override
  Future<IThreadCommunication> obtainConnectionEntityManagerFromServer<T>() async {
    final channel = ChannelIsolates.createInitialChannelManually();
    final senderEntity = await callFunctionOnTheServer(function: _getEntitySenderFromServer<T>, parameters: InvocationParameters.only(channel.serder));

    channel.defineSender(senderEntity);
    final port = ThreadCommunicationMethodIsolator(channel: channel);

    return ThreadComunicationStandar(managerThisTread: this, port: port);
  }

  static Future<SendPort> _getEntitySenderFromServer<T>(InvocationParameters parameter) async {
    final inputSender = parameter.firts<SendPort>();
    final server = ThreadManager.getProcess();

    checkProgrammingFailure(thatChecks: () => 'The invocation is not being done on a thread server', result: () => server is IThreadProcessServer);

    final entity = await volatile(
      detail: () => 'The thread is not an AbylitysThreadLinkedSender',
      function: () async => (await server.searchEntityManager<T>()) as AbylitysThreadLinkedSender,
    );

    return entity.linkedIsolator(inputSender);
  }
}
