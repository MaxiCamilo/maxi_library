import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/isolates/ithread_isolador.dart';

class IsolatedThreadStreamManager {
  final IThreadInvoker manager;

  final _connectedStreams = <int, StreamController>{};
  final _createdStreams = <int, StreamSubscription>{};

  int _lastDestinationID = 1;

  IsolatedThreadStreamManager({required this.manager});

  Future<Stream<R>> createSharedStream<R>({
    required InvocationParameters parameters,
    required FutureOr<Stream<R>> Function(InvocationContext) function,
    required IThreadInvoker invoker,
  }) async {
    final id = _lastDestinationID;
    _lastDestinationID += 1;

    parameters = InvocationParameters.clone(parameters)
      ..namedParameters['_#FS()#_'] = function
      ..namedParameters['_#ID#_'] = id;

    await invoker.callFunction(parameters: parameters, function: _createStreamInThread<R>);

    final controller = StreamController<R>();

    _connectedStreams[id] = controller;

    return controller.stream.doOnCancel(() {
      final instance = _connectedStreams.remove(id);
      if (instance != null) {
        invoker.callFunction(parameters: InvocationParameters.only(id), function: _declareCanceled);
      }
    });
  }

  Future<void> close() async {
    _connectedStreams.values.iterar((x) => x.close());
    _connectedStreams.clear();

    _createdStreams.values.iterar((x) => x.cancel());
    _createdStreams.clear();

    await Future.delayed(Duration.zero);
  }

  Future<Stream<R>> createSharedStreamOnEntity<T extends Object, R>({
    required InvocationParameters parameters,
    required FutureOr<Stream<R>> Function(T, InvocationContext) function,
    required IThreadInvoker invoker,
  }) {
    parameters = InvocationParameters.clone(parameters)..namedParameters['_#EFS()#_'] = function;
    return createSharedStream(invoker: invoker, parameters: parameters, function: _createStreamInEntityThread<T, R>);
  }

  static Future<Stream<R>> _createStreamInEntityThread<T extends Object, R>(InvocationContext context) async {
    final function = context.named<FutureOr<Stream<R>> Function(T, InvocationContext)>('_#EFS()#_');

    final entity = await volatileAsync<T>(detail: Oration(message: 'Thread does not handle entity of type %1', textParts: [T]), function: () async => (await context.thread.getEntity<T>()) as T);

    return await function(entity, context);
  }

  static void _declareCanceled(InvocationContext context) {
    final server = context.sender as IThreadIsolador;
    final subscription = server.streamManager._createdStreams.remove(context.firts<int>());

    if (subscription != null) {
      subscription.cancel();
    }
  }

  static Future<void> _createStreamInThread<R>(InvocationContext context) async {
    final id = context.named<int>('_#ID#_');
    final function = context.named<FutureOr<Stream<R>> Function(InvocationContext)>('_#FS()#_');
    final server = context.sender as IThreadIsolador;

    final stream = await function(context);

    final subscription = stream.listen(
        (x) => context.sender.callFunction(
              parameters: InvocationParameters.list([id, x]),
              function: _declareNewItem<R>,
            ),
        onError: (x, y) => context.sender.callFunction(
              parameters: InvocationParameters.list([id, x, y]),
              function: _declareError,
            ),
        onDone: () {
          if (server.streamManager._createdStreams.remove(id) != null) {
            context.sender.callFunction(
              parameters: InvocationParameters.list([id]),
              function: _declareFinished,
            );
          }
        });

    server.streamManager._createdStreams[id] = subscription;
  }

  static void _declareNewItem<R>(InvocationContext context) {
    final id = context.firts<int>();
    final item = context.second<R>();

    final streamManager = (context.sender as IThreadIsolador).streamManager;

    final instance = streamManager._connectedStreams[id];
    if (instance == null) {
      log('[IsolatedThreadStreamManager] Instance with ID $id cannot be found');
      return;
    }

    instance.add(item);
  }

  static void _declareError(InvocationContext context) {
    final id = context.firts<int>();
    final error = context.second<Object>();
    final stackTrace = context.third<StackTrace?>();

    final streamManager = (context.sender as IThreadIsolador).streamManager;

    final instance = streamManager._connectedStreams[id];
    if (instance == null) {
      log('[IsolatedThreadStreamManager] Instance with ID $id cannot be found');
      return;
    }

    instance.addError(error, stackTrace);
  }

  static void _declareFinished(InvocationContext context) {
    final id = context.firts<int>();
    final streamManager = (context.sender as IThreadIsolador).streamManager;

    final instance = streamManager._connectedStreams.remove(id);
    if (instance == null) {
      return;
    }

    instance.close();
  }
}
