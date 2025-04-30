import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/interfaces/iisolate_thread_channel_manager.dart';
import 'package:maxi_library/src/threads/isolates/isolated_thread_stream_manager.dart';

mixin IThreadIsolador on IThreadInvoker {
  IIsolateThreadChannelManager get channelsManager;
  IsolatedThreadStreamManager get streamManager;
}
