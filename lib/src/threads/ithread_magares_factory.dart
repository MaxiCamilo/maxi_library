import 'package:maxi_library/maxi_library.dart';

mixin IThreadManagersFactory {
  IThreadManager createServer({required List<IThreadInitializer> threadInitializer});
}
