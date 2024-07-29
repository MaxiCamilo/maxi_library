import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/operators/ithread_communication.dart';
import 'package:maxi_library/src/threads/operators/ithread_magares_factory.dart';

mixin IThreadProcess on IThreadInvoker {
  IThreadManagersFactory get implementation;

  Future<IThreadCommunication> searchEntityManager<T>();

  void reactConnectionClose(IThreadCommunication closedCommunicator);
}
