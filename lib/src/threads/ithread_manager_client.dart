import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/ithread_invoke_instance.dart';

mixin IThreadManagerClient on IThreadInvoker, IThreadManager {
  IThreadInvokeInstance get serverConnection;

  Future<IThreadInvokeInstance> requestConnectionForService<T>();

  Future<void> defineAsService({required Object newEntity});

  Future<dynamic> getConnectionTip();
}
