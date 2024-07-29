import 'package:maxi_library/src/threads/operators/ithread_communication.dart';
import 'package:maxi_library/src/threads/operators/ithread_process.dart';

class ContextProcessThreadMessages {
  final IThreadCommunication communicator;
  final IThreadProcess managerThisThread;

  const ContextProcessThreadMessages({required this.communicator, required this.managerThisThread});
}
