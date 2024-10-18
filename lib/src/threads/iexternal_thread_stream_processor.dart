import 'package:maxi_library/maxi_library.dart';

mixin ThreadPipeProcessor {
  ThreadPipe<R, S> createExternalStream<R, S>();

  Future<void> confirmStarted({required int streamID, required int threadID, required int externID});

  void notifyNewItem({required int streamID, required bool isExternalPipe, required dynamic item});

  void notifyNewError({required int streamID, required bool isExternalPipe, required Object error, StackTrace? stackTrace});

  void notifyPipeClosure({required int streamID, required bool isExternalPipe});

  void removePipe({required int streamID, required bool isExternalPipe});
}
