import 'package:maxi_library/maxi_library.dart';

mixin IThreadManagersFactory {
  IThreadInvoker createServer({required List<IThreadInitializer> threadInitializer});
}
