import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/isolates/ithread_isolador.dart';

class DestinationIsolatedThreadStream<R, S> with IPipe<R, S>, StartableFunctionality {
  final int destinationID;
  final int originID;

  late final IThreadInvoker sender;

  bool _isActive = false;
  late final Completer<IPipe<R, S>> _onDone;
  late final StreamController<R> _receive;

  DestinationIsolatedThreadStream({required this.destinationID, required this.originID});

  @override
  Stream<R> get stream => _receive.stream;

  @override
  bool get isActive => _isActive;

  @override
  Future<void> initializeFunctionality() async {
    volatile(detail: Oration(message: 'Invocator was not defined'), function: () => sender.isServer);

    _onDone = Completer<IPipe<R, S>>();
    _receive = StreamController<R>.broadcast();

    _isActive = true;
  }

  @override
  Future get done => _onDone.future;

  void receiveItem(R item) {
    _receive.add(item);
  }

  void receiveError(Object error, StackTrace? stackTrace) {
    _receive.addError(error, stackTrace);
  }

  void declareClosed() {
    if (!_isActive) {
      return;
    }

    _isActive = false;
    _onDone.completeIfIncomplete(this);
    _receive.close();
  }

  @override
  void add(S event) {
    sender.callFunction(parameters: InvocationParameters.list([originID, event]), function: _sendItem<S>);
  }

  static Future<void> _sendItem<S>(InvocationContext context) async {
    final id = context.firts<int>();
    final item = context.second<S>();

    final thread = volatile(detail: Oration(message: 'Thread is not Isolator'), function: () => context.thread as IThreadIsolador);
    thread.pipelineManager.getOriginStream(id).receiveItem(item);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    sender.callFunction(parameters: InvocationParameters.list([originID, error, stackTrace]), function: _sendError);
  }

  static Future<void> _sendError<S>(InvocationContext context) async {
    final id = context.firts<int>();
    final error = context.second<Object>();
    final stackTrace = context.third()<StackTrace?>();

    final thread = volatile(detail: Oration(message: 'Thread is not Isolator'), function: () => context.thread as IThreadIsolador);
    thread.pipelineManager.getOriginStream(id).receiveError(error, stackTrace);
  }

  @override
  Future close() async {
    if (!_isActive) {
      return;
    }

    await sender.callFunction(
        parameters: InvocationParameters.list([
          originID,
        ]),
        function: _declareClosed);

    declareClosed();
  }

  static Future _declareClosed(InvocationContext context) async {
    final id = context.firts<int>();

    final thread = volatile(detail: Oration(message: 'Thread is not Isolator'), function: () => context.thread as IThreadIsolador);

    thread.pipelineManager.getOriginStream(id).declareClosed();
  }

  @override
  Future addStream(Stream<S> stream) async {
    if (!_isActive) {
      log('[DestinationIsolatedThreadStream] The pipe is closed');
      return;
    }

    final compelteter = Completer();

    final subscription = stream.listen(
      (x) => add(x),
      onError: (x, y) => addError(x, y),
      onDone: () => compelteter.completeIfIncomplete(),
    );

    final future = done.whenComplete(() => compelteter.completeIfIncomplete());

    await compelteter.future;

    subscription.cancel();
    future.ignore();
  }
}
