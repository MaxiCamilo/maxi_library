import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/abilitys/iability_send_thread_messages.dart';
import 'package:maxi_library/src/threads/operators/iexecutor_requested_thread_stream.dart';
import 'package:maxi_library/src/threads/operators/ithread_process_entity.dart';
import 'package:maxi_library/src/threads/operators/ithread_message.dart';
import 'package:maxi_library/src/threads/operators/ithread_process.dart';
import 'package:maxi_library/src/threads/messages/streams/message_stream_error.dart';
import 'package:maxi_library/src/threads/messages/streams/message_stream_execute.dart';
import 'package:maxi_library/src/threads/messages/streams/message_stream_finalize.dart';
import 'package:maxi_library/src/threads/messages/streams/message_stream_item.dart';

class ExecutorRequestThreadStreamStandar with IExecutorRequestedThreadStream {
  final IAbilitySendThreadMessages sender;
  final IThreadProcess manager;

  final _activeStreams = <int, StreamSubscription>{};

  int _lastIdStram = 0;

  bool _isActive = true;

  ExecutorRequestThreadStreamStandar({required this.sender, required this.manager});

  @override
  Future<void> executeRequestedEntityStream<T>({required InvocationParameters parameters, required Future<Stream> Function(T, InvocationParameters) function}) async {
    final newId = _getNewId();

    late final Stream flow;

    try {
      final entity = IThreadProcessEntity.getItemFromProcess<T>(manager);
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

      _activeStreams[newId] = subscription;
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

      _activeStreams[newId] = subscription;
    } catch (ex) {
      await _sendStreamFailure(newId, ex, null);
      return;
    }
  }

  @override
  void cancelStream(int idStream) {
    final flow = _activeStreams[idStream];

    if (flow == null) {
      log('[ExecutorRequestThreadStreamStandar] The stream N° $idStream non exists');
      return;
    }    

    containErrorLog(detail: 'Cancel stream N° $idStream', function: () => flow.cancel());
  }

  @override
  void reactClosingThread() {
    _isActive = false;
    for (final item in _activeStreams.entries) {
      item.value.cancel();
    }
  }

  int _getNewId() {
    final newId = _lastIdStram;
    _lastIdStram += 1;

    return newId;
  }

  Future<void> _sendReplyMessage(String detail, IThreadMessage messege) async {
    if (!_isActive) {
      log('[ExecutorRequestThreadStreamStandar] WARNING!: The executor of stream is inactive, but an attempt was made to send a message ("$detail")');
      return;
    }

    await containErrorLogAsync(
      detail: () => detail,
      function: () => sender.sendMessage(messege),
    );
  }

  Future<void> _sendStreamStart(int id, Type? entity) {
    return _sendReplyMessage(
      'Sending confirmation of running stream N° $id ${entity == null ? '(Anonymous)' : '(entity $entity)'}',
      MessageStreamExecute(idStram: id, isCorrect: true, error: null),
    );
  }

  Future<void> _sendStreamFailure(int id, dynamic error, Type? entity) {
    return _sendReplyMessage(
      'Sending confirmation of failure stream N° $id ${entity == null ? '(Anonymous)' : '(entity $entity)'}',
      MessageStreamExecute(idStram: id, isCorrect: false, error: error),
    );
  }

  Future<void> _sendStreamItem(int id, dynamic item, Type? entity) {
    return _sendReplyMessage(
      'sending the stream item N° $id ${entity == null ? '(Anonymous)' : '(entity $entity)'}',
      MessageStreamItem(idStrem: id, item: item),
    );
  }

  Future<void> _sendStreamError(int id, dynamic error, Type? entity) {
    return _sendReplyMessage(
      'sending the stream error N° $id ${entity == null ? '(Anonymous)' : '(entity $entity)'}',
      MessageStreamError(idStream: id, error: error),
    );
  }

  Future<void> _sendStreamFinalize(int id, Type? entity) {
    _activeStreams.remove(id);
    return _sendReplyMessage(
      'sending the stream closure notification N° $id ${entity == null ? '(Anonymous)' : '(entity $entity)'}',
      MessageStreamFinalize(idStream: id),
    );
  }
}
