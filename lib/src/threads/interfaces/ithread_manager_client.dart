import 'package:maxi_library/maxi_library.dart';

mixin IThreadManagerClient on IThreadInvoker, IThreadManager {
  IThreadInvokeInstance get serverConnection;

  //Future<IThreadInvokeInstance> requestConnectionForService<T>();

  //Future<dynamic> getConnectionTip();
}
