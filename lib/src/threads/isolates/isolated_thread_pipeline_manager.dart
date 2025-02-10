import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/isolates/destination_isolated_thread_stream.dart';
import 'package:maxi_library/src/threads/isolates/ithread_isolador.dart';
import 'package:maxi_library/src/threads/isolates/origin_isolated_thread_stream.dart';

class IsolatedThreadPipelineManager {
  final IThreadIsolador thread;

  int _lastOriginID = 1;
  int _lastDestinationID = 1;

  final _destinationStreams = <DestinationIsolatedThreadStream>[];
  final _originStreams = <OriginIsolatedThreadStream>[];

  IsolatedThreadPipelineManager({required this.thread});

  DestinationIsolatedThreadStream getDestinationStream(int id) => volatile(
      detail: Oration(message: 'Origin Pipe is not found (ID %1)', textParts: [id]),
      function: () => _destinationStreams.selectItem(
            (x) => x.destinationID == id,
          )!);

  OriginIsolatedThreadStream getOriginStream(int id) => volatile(
      detail: Oration(message: 'Origin Pipe is not found (ID %1)', textParts: [id]),
      function: () => _originStreams.selectItem(
            (x) => x.originID == id,
          )!);

  Future<DestinationIsolatedThreadStream<S, R>> createPipeline<R, S>({
    required InvocationParameters parameters,
    required FutureOr<void> Function(InvocationContext, IPipe<R, S>) function,
    required IThreadInvoker sender,
  }) async {
    final id = _lastDestinationID;
    _lastDestinationID += 1;

    parameters = InvocationParameters.clone(parameters)
      ..namedParameters['_#PF()#_'] = function
      ..namedParameters['_#ID#_'] = id;

    final newPipe = await sender.callFunction(parameters: parameters, function: _createPipelineInThread<R, S>);
    newPipe.sender = sender;
    await newPipe.initialize();

    _destinationStreams.add(newPipe);
    newPipe.done.whenComplete(() => _destinationStreams.remove(newPipe));

    return newPipe;
  }

  static Future<DestinationIsolatedThreadStream<S, R>> _createPipelineInThread<R, S>(InvocationContext context) async {
    final destinationID = context.named<int>('_#ID#_');
    final function = context.named<FutureOr<void> Function(InvocationContext, IPipe<R, S>)>('_#PF()#_');
    final thread = context.thread as IThreadIsolador;
    final pipelineManager = thread.pipelineManager;

    final originID = thread.pipelineManager._lastOriginID;
    thread.pipelineManager._lastOriginID += 1;

    final newPipe = OriginIsolatedThreadStream<R, S>(sender: context.sender, destinationID: destinationID, originID: originID);
    pipelineManager._addOriginStream(newPipe);

    scheduleMicrotask(() async {
      try {
        await function(context, newPipe);
      } catch (ex, st) {
        newPipe.addError(ex, st);
        scheduleMicrotask(() => newPipe.close());
      }
    });

    return newPipe.createDestination();
  }

  void _addOriginStream<R, S>(OriginIsolatedThreadStream<R, S> origin) {
    _originStreams.add(origin);
    origin.done.whenComplete(() => _originStreams.remove(origin));
  }

  Future<DestinationIsolatedThreadStream<S, R>> createEntityPipeline<T extends Object, R, S>({
    required InvocationParameters parameters,
    required FutureOr<void> Function(T, InvocationContext, IPipe<R, S>) function,
    required IThreadInvoker sender,
  }) {
    parameters = InvocationParameters.clone(parameters)..namedParameters['_#EF()#_'] = function;
    return createPipeline(function: _createEntityPipelineInThread<T, R, S>, parameters: parameters, sender: sender);
  }

  static Future<void> _createEntityPipelineInThread<T extends Object, R, S>(InvocationContext context, IPipe<R, S> pipe) async {
    final entity = await volatileAsync(detail: Oration(message: 'Thread does not have entity %1', textParts: [T]), function: () async => (await context.thread.getEntity<T>())!);
    final function = context.named<FutureOr<void> Function(T, InvocationContext, IPipe<R, S>)>('_#EF()#_');
    return await function(entity, context, pipe);
  }
}
