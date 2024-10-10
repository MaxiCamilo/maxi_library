
import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/ithread_invoke_instance.dart';

mixin IThreadManager on IThreadInvoker{
  dynamic get entity;

  List<IThreadInvokeInstance> get connections;
  Map<Type, IThreadInvokeInstance> get connectionWithServices;

  void closeThread();
}
