import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/operators/ithread_process.dart';

mixin IThreadProcessIsolate on IThreadInvoker, IThreadProcess {
  void requestThreadTermination();
}
