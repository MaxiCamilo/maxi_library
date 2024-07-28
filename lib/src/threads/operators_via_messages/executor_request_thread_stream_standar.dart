import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/abilitys/iability_send_thread_messages.dart';
import 'package:maxi_library/src/threads/iexecutor_requested_thread_stream.dart';
import 'package:maxi_library/src/threads/ithread_entity.dart';
import 'package:maxi_library/src/threads/ithread_process.dart';
import 'package:maxi_library/src/threads/messages/streams/message_stream_error.dart';
import 'package:maxi_library/src/threads/messages/streams/message_stream_execute.dart';
import 'package:maxi_library/src/threads/messages/streams/message_stream_finalize.dart';
import 'package:maxi_library/src/threads/messages/streams/message_stream_item.dart';

class ExecutorRequestThreadStreamStandar with IExecutorRequestedThreadStream {
  final IAbilitySendThreadMessages sender;
  final IThreadProcess manager;

  Map<int, StreamSubscription> activeStreams = {};

  int _lastIdStram = 0;

  ExecutorRequestThreadStreamStandar({required this.sender, required this.manager});

  @override
  Future<void> executeRequestedEntityStream<T>({required InvocationParameters parameters, required Future<Stream> Function(T, InvocationParameters) function}) async {
    final newId = _getNewId();

    late final Stream flow;

    try {
      final entity = IThreadEntity.getItemFromProcess<T>(manager);
      flow = await function(entity, parameters);
      await _sendStreamStart(newId, T);
      final subscription = programmingFailure(
        reasonFailure: () => 'The function returns a non-broadcast stream or is busy',
        function: () => flow.listen(
          (x) => _sendStreamItem(newId, x, T),
          onError: (x) => _sendStreamError(newId, x, T),
          onDone: () => _sendStreamFinalize(newId, T),
        ),
      );

      activeStreams[newId] = subscription;
    } catch (ex) {
      await _sendStreamFailure(newId, ex, T);
      return;
    }
  }

  @override
  Future<void> executeRequestedStream({required InvocationParameters parameters, required Future<Stream> Function(InvocationParameters) function}) async {
    final newId = _getNewId();

    late final Stream flow;

    try {
      flow = await function(parameters);
      await _sendStreamStart(newId, null);
      final subscription = programmingFailure(
        reasonFailure: () => 'The function returns a non-broadcast stream or is busy',
        function: () => flow.listen(
          (x) => _sendStreamItem(newId, x, null),
          onError: (x) => _sendStreamError(newId, x, null),
          onDone: () => _sendStreamFinalize(newId, null),
        ),
      );

      activeStreams[newId] = subscription;
    } catch (ex) {
      await _sendStreamFailure(newId, ex, null);
      return;
    }
  }

  int _getNewId() {
    final newId = _lastIdStram;
    _lastIdStram += 1;

    return newId;
  }

  Future<void> _sendStreamStart(int id, Type? entity) {
    return containErrorLogAsync(
      detail: () => 'Sending confirmation of running stream N° $id ${entity == null ? '(Anonymous)' : '(entity $entity)'}',
      function: () => sender.sendMessage(
        MessageStreamExecute(idStram: id, isCorrect: true, error: null),
      ),
    );
  }

  Future<void> _sendStreamFailure(int id, dynamic error, Type? entity) {
    return containErrorLogAsync(
      detail: () => 'Sending confirmation of failure stream N° $id ${entity == null ? '(Anonymous)' : '(entity $entity)'}',
      function: () => sender.sendMessage(
        MessageStreamExecute(idStram: id, isCorrect: false, error: error),
      ),
    );
  }

  Future<void> _sendStreamItem(int id, dynamic item, Type? entity) {
    return containErrorLogAsync(
      detail: () => 'sending the stream item N° $id ${entity == null ? '(Anonymous)' : '(entity $entity)'}',
      function: () => sender.sendMessage(
        MessageStreamItem(idStrem: id, item: item),
      ),
    );
  }

  Future<void> _sendStreamError(int id, dynamic error, Type? entity) {
    return containErrorLogAsync(
      detail: () => 'sending the stream error N° $id ${entity == null ? '(Anonymous)' : '(entity $entity)'}',
      function: () => sender.sendMessage(
        MessageStreamError(idStream: id, error: error),
      ),
    );
  }

  Future<void> _sendStreamFinalize(int id, Type? entity) {
    activeStreams.remove(id);
    return containErrorLogAsync(
      detail: () => 'sending the stream closure notification N° $id ${entity == null ? '(Anonymous)' : '(entity $entity)'}',
      function: () => sender.sendMessage(
        MessageStreamFinalize(idStream: id),
      ),
    );
  }

  @override
  void cancelStream(int idStream) {
    final flow = activeStreams[idStream];

    if (flow == null) {
      log('[ExecutorRequestThreadStreamStandar] The stream N° $idStream non exists');
      return;
    }

    containErrorLog(detail: () => 'Cancel stream N° $idStream', function: () => flow.cancel());
  }
}
