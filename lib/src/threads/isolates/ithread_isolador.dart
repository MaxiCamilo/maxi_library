import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/isolates/isolated_thread_pipeline_manager.dart';
import 'package:maxi_library/src/threads/isolates/isolated_thread_stream_manager.dart';

mixin IThreadIsolador on IThreadInvoker {
  IsolatedThreadPipelineManager get pipelineManager;
  IsolatedThreadStreamManager get streamManager;
}
