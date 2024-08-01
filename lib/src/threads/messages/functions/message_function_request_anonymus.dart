import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/context_process_thread_messages.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_message.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_server.dart';

class MessageFunctionRequestAnonymus<R> with IThreadMessage {
  final InvocationParameters parameters;
  final Future<R> Function(InvocationParameters) function;

  const MessageFunctionRequestAnonymus({required this.parameters, required this.function});

  @override
  Future<void> openMessage({required ContextProcessThreadMessages context}) {
    if (context.managerThisThread is IThreadProcessServer) {
      throw UnimplementedError('[MAXI] ¡Hey, this is beguin used!');
      //THIS MUST RETURN the new ID of the task
      //return context.managerThisThread.callFunctionAsAnonymous(function: function, parameters: parameters);
    } else {
      return context.communicator.executorRequestFunction.executeRequestedFunction(parameters: parameters, function: function);
    }
  }
}
