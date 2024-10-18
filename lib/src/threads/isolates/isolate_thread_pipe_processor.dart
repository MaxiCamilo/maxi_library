import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/iexternal_thread_stream_processor.dart';
import 'package:maxi_library/src/threads/isolates/isolate_thread_pipe.dart';

class IsolateThreadPipeProcessor with ThreadPipeProcessor {
  final actualStreams = <IsolateThreadPipe>[];
  final externsStreams = <IsolateThreadPipe>[];

  int _lastId = 1;
  int _lastExternalId = 50;

  int addExternalPipe({required IsolateThreadPipe pipe}) {
    final newId = _lastExternalId;
    _lastExternalId += 1;

    externsStreams.add(pipe);

    return newId;
  }

  @override
  ThreadPipe<R, S> createExternalStream<R, S>() {
    final id = _lastId;
    _lastId += 1;
    final newStream = IsolateThreadPipe<R, S>(identifier: id);

    actualStreams.add(newStream);
    return newStream;
  }

  IsolateThreadPipe getStreamFromID({required int id, required bool isExternalPipe}) {
    final selectedStream = isExternalPipe ? externsStreams.selectItem((x) => x.externalID == id) : actualStreams.selectItem((x) => x.identifier == id);
    if (selectedStream == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: tr('External stream %1 was not found'),
      );
    } else {
      return selectedStream;
    }
  }

  @override
  Future<void> confirmStarted({required int streamID, required int threadID, required int externID}) async {
    final stream = getStreamFromID(id: streamID, isExternalPipe: false);
    final thread = await ThreadManager.instance.locateConnection(threadID);

    stream.confirmStarted(connection: thread, externalID: externID);
  }

  @override
  void notifyNewError({required int streamID, required bool isExternalPipe, required Object error, StackTrace? stackTrace}) {
    getStreamFromID(id: streamID, isExternalPipe: isExternalPipe).receiver.addError(error, stackTrace);
  }

  @override
  void notifyNewItem({required int streamID, required bool isExternalPipe, required item}) {
    getStreamFromID(id: streamID, isExternalPipe: isExternalPipe).receiveData(item);
  }

  @override
  void notifyPipeClosure({required bool isExternalPipe, required int streamID}) {
    if (isExternalPipe) {
      final externPipe = externsStreams.selectItem((x) => x.externalID == streamID);
      if (externPipe != null) {
        externPipe.defineClosed();
      }
    } else {
      final selectedStream = actualStreams.selectItem((x) => x.identifier == streamID);
      if (selectedStream != null) {
        selectedStream.defineClosed();
      }
    }
  }

  @override
  void removePipe({required bool isExternalPipe, required int streamID}) {
    if (isExternalPipe) {
      final externPipe = externsStreams.selectItem((x) => x.externalID == streamID);
      if (externPipe != null) {
        externsStreams.remove(externPipe);
        externPipe.defineClosed();
      }
    } else {
      final selectedStream = actualStreams.selectItem((x) => x.identifier == streamID);
      if (selectedStream != null) {
        actualStreams.remove(selectedStream);
        selectedStream.defineClosed();
      }
    }
  }
}
