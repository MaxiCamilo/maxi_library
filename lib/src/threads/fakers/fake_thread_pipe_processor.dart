import 'package:maxi_library/src/threads/iexternal_thread_stream_processor.dart';
import 'package:maxi_library/src/threads/thread_pipe.dart';

class FakeThreadPipeProcessor with ThreadPipeProcessor{
  @override
  Future<void> confirmStarted({required int streamID, required int threadID, required int externID}) {
    throw UnimplementedError();
  }

  @override
  ThreadPipe<R, S> createExternalStream<R, S>() {
    throw UnimplementedError();
  }

  @override
  void notifyNewError({required int streamID, required bool isExternalPipe, required Object error, StackTrace? stackTrace}) {
     throw UnimplementedError();
  }

  @override
  void notifyNewItem({required int streamID, required bool isExternalPipe, required item}) {
     throw UnimplementedError();
  }

  @override
  void notifyPipeClosure({required int streamID, required bool isExternalPipe}) {
     throw UnimplementedError();
  }

  @override
  void removePipe({required int streamID, required bool isExternalPipe}) {
     throw UnimplementedError();
  }

}