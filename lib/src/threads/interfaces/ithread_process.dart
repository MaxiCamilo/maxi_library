import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_communication.dart';

mixin IThreadProcess on IThreadInvoker {

  Future<IThreadCommunication> searchEntityManager<T>();

  void reactConnectionClose(IThreadCommunication closedCommunicator);
}
