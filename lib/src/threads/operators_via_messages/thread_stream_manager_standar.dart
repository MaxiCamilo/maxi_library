import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/abilitys/iability_send_thread_messages.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_message.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_stream_manager.dart';
import 'package:maxi_library/src/threads/messages/streams/message_stream_cancel.dart';
import 'package:maxi_library/src/threads/messages/streams/message_stream_request_anonymous.dart';
import 'package:maxi_library/src/threads/messages/streams/message_stream_request_entity.dart';

class ThreadStreamManagerStandar with IThreadStreamManager {
  final IAbilitySendThreadMessages sender;
  final IThreadProcess manager;

  final _activeStreams = <int, StreamController>{};
  final _synchronizerRequests = Semaphore();

  int _lastId = 0;
  bool _isActive = true;
  Completer<int>? _identifierWaiter;

  ThreadStreamManagerStandar({required this.sender, required this.manager});

  @override
  Future<Stream<R>> callEntityStream<T, R>({
    InvocationParameters parameters = InvocationParameters.emptry,
    required Future<Stream<R>> Function(T p1, InvocationParameters p2) function,
  }) async {
    _checkIfThreadActive();
    final controllerResult = await _synchronizerRequests.execute(
      function: () async => await _sendSolicitud<R>(
        message: MessageStreamRequestEntity<T, R>(
          parameters: parameters,
          function: function,
        ),
      ),
    );

    final stream = controllerResult.$2.stream;
    return stream;
  }

  @override
  Future<Stream<R>> callStreamAsAnonymous<R>({
    InvocationParameters parameters = InvocationParameters.emptry,
    required Future<Stream<R>> Function(InvocationParameters p1) function,
  }) async {
    _checkIfThreadActive();
    final controllerResult = await _synchronizerRequests.execute(
      function: () async => await _sendSolicitud<R>(
        message: MessageStreamRequestAnonymous<R>(
          parameters: parameters,
          function: function,
        ),
      ),
    );

    final stream = controllerResult.$2.stream;

    controllerResult.$2.onCancel = () => _reactCancelController(controllerResult.$1);

    return stream;
  }

  @override
  void cancelStream(int idStream) {
    final item = _searchController(idStream);
    if (item != null) {
      containErrorLog(
        detail: '[ThreadStreamManagerStandar] FAILED!: Controller number $idStream failed to close due to cancelation',
        function: () => item.close(),
      );
    }
  }

  @override
  void confirmStreamEnd(int idStream) {
    final item = _searchController(idStream);
    if (item != null) {
      _activeStreams.remove(idStream);
      containErrorLog(
        detail: '[ThreadStreamManagerStandar] FAILED!: Controller number $idStream failed to close due to finalized',
        function: () => item.close(),
      );
    }
  }

  @override
  void confirmStreamError(int idStream, failure) {
    final stream = _searchController(idStream);
    if (stream != null) {
      containErrorLog(
        detail: '[ThreadStreamManagerStandar] FAILED!: Controller number $idStream failed to send error',
        function: () => stream.addError(failure),
      );
    }
  }

  @override
  void confirmStreamFailure(int idStream, error) {
    if (_identifierWaiter == null || _identifierWaiter!.isCompleted) {
      log('[ThreadStreamManagerStandar] FAILED!: The start of stream number $idStream was not expected');
      return;
    }

    _identifierWaiter!.completeError(idStream, error);
  }

  @override
  void confirmStreamItem(int idStream, item) {
    final stream = _searchController(idStream);
    if (stream != null) {
      if (!stream.isClosed) {
        containErrorLog(
          detail: '[ThreadStreamManagerStandar] FAILED!:a Controlled number $idStream did not accept the value received (${item.runtimeType})',
          function: () => stream.add(item),
        );
      }
    }
  }

  @override
  void confirmStreamRunning(int idStream) {
    if (_identifierWaiter == null || _identifierWaiter!.isCompleted) {
      log('[ThreadStreamManagerStandar] WARNING!: The start of stream number $idStream was not expected');
      return;
    }

    _identifierWaiter!.complete(idStream);
  }

  void _checkIfThreadActive() {
    if (!_isActive) {
      throw NegativeResult(
        identifier: NegativeResultCodes.functionalityCancelled,
        message: 'The thread/subthread finished its execution',
      );
    }
  }

  StreamController? _searchController(int idStream) {
    final item = _activeStreams[idStream];
    if (item == null) {
      log('[ThreadStreamManagerStandar] WARNING!: When searching for controller number $idStream, it does not exist');
    }

    return item;
  }

  Future<(int, StreamController<R>)> _sendSolicitud<R>({required IThreadMessage message}) async {
    _identifierWaiter = Completer<int>();
    await sender.sendMessage(message);

    final receivedId = await _identifierWaiter!.future;
    if (_lastId != receivedId) {
      log('[ThreadStreamManagerStandar] WARNING!: The last id is "$_lastId", but id $_identifierWaiter was received');
    }

    _lastId = receivedId + 1;
    final contoller = StreamController<R>.broadcast();

    contoller.onCancel = () => _reactCancelController(receivedId);

    _activeStreams[receivedId] = contoller;

    return (receivedId, contoller);
  }

  _reactCancelController(int receivedId) {
    final controller = _activeStreams[receivedId];
    if (controller != null) {
      sender.sendMessage(
        MessageStreamCancel(idStream: receivedId),
      );
      controller.close();

      _activeStreams.remove(receivedId);
    }
  }

  @override
  void reactClosingThread() {
    _isActive = false;

    final error = NegativeResult(
      identifier: NegativeResultCodes.functionalityCancelled,
      message: 'The function was canceled because the thread/subthread finished its execution',
    );

    _activeStreams.entries.map(
      (x) => containErrorLog(
        detail: '[ThreadStreamManagerStandar] FAILED!: Controller number ${x.key} failed to send error',
        function: () => x.value.addError(error),
      ),
    );

    _activeStreams.entries.map((x) => x.value.close());

    _activeStreams.clear();
  }
}
