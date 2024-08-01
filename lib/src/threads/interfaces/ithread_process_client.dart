import 'package:maxi_library/src/threads/interfaces/ithread_communication.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process.dart';

mixin IThreadProcessClient on IThreadProcess {
  IThreadCommunication get serverCommunicator;
}
