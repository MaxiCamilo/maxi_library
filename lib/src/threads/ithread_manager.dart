import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/iexternal_thread_stream_processor.dart';
import 'package:maxi_library/src/threads/ithread_invoke_instance.dart';

mixin IThreadManager on IThreadInvoker {
  int get threadID;
  dynamic get entity;
  ThreadPipeProcessor get pipeProcessor;

  List<IThreadInvokeInstance> get connections;
  Map<Type, IThreadInvokeInstance> get connectionWithServices;

  Future<IThreadInvokeInstance> locateConnection(int id);

  void closeThread();
}
