import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/ithread_invoke_instance.dart';

mixin IThreadManagerServer on IThreadInvoker, IThreadManager {
  void addThreadInitializer({required IThreadInitializer initializer});

  Future<IThreadInvokeInstance> makeNewThread({required List<IThreadInitializer> initializers, required String name });

  Future<dynamic> getRawConnectionAccordingToEntity<T>();
}
