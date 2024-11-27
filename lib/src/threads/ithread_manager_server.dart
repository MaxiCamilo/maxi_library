import 'package:maxi_library/maxi_library.dart';

mixin IThreadManagerServer on IThreadInvoker, IThreadManager {
  void addThreadInitializer({required IThreadInitializer initializer});

  Future<IThreadInvokeInstance> makeNewThread({required List<IThreadInitializer> initializers, required String name });

  //Future<dynamic> getRawConnectionAccordingToEntity<T>();

  //Future<dynamic> getRawConnectionAccordingToID(int id);
}
