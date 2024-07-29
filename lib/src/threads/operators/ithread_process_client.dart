import 'package:maxi_library/src/threads/operators/ithread_communication.dart';

mixin IThreadProcessClient {
  IThreadCommunication get serverCommunicator;

  Future<IThreadCommunication> obtainConnectionEntitysManager<T>();
}
