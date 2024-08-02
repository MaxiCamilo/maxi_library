import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_communication.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_server.dart';

mixin TemplateThreadProcessServer on IThreadInvoker, IThreadProcess, IThreadProcessServer {
  List<IThreadInitializer> get threadInitializer;

  final mapConnectionsEntity = <Type, IThreadCommunication>{};

  @override
  final listAnonymousCommunicatios = <IThreadCommunication>[];

  final listAnonymousBackgroundCommunicatios = <IThreadCommunication>[];
  final List<IThreadCommunication> _listOccupiedAnonymousCommunicators = [];
  final List<IThreadCommunication> _listFreeAnonymousCommunicators = [];

  final _newThreadsSynchronizer = Semaphore();
  final _newBackgroudThreadsSynchronizer = Semaphore();

  Future<IThreadCommunication> createEntitysManagerAccordingImplementation<T>({required T item, required List<IThreadInitializer> initializers});

  Future<IThreadCommunication> createAnonymousManagerAccordingImplementation({required String name, required List<IThreadInitializer> initializers});

  @override
  Future<R> callEntityFunction<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(T, InvocationParameters) function}) async {
    final communicator = await searchEntityManager<T>();
    return await communicator.requestManager.callEntityFunction(parameters: parameters, function: function);
  }

  @override
  Future<Stream<R>> callEntityStream<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(T p1, InvocationParameters p2) function}) async {
    final communicator = await searchEntityManager<T>();
    return await communicator.streamManager.callEntityStream(parameters: parameters, function: function);
  }

  @override
  Future<R> callFunctionAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationParameters p1) function}) async {
    final thread = await _reserveBackgroundThread();

    return await thread.requestManager.callFunctionAsAnonymous(function: function, parameters: parameters).whenComplete(() {
      _listOccupiedAnonymousCommunicators.remove(thread);
      _listFreeAnonymousCommunicators.add(thread);
    });
  }

  @override
  Future<Stream<R>> callStreamAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(InvocationParameters p1) function}) async {
    final thread = await _reserveBackgroundThread();

    final stream = await volatileAsync(
      detail: () => tr('Call anonymous stream'),
      function: () => thread.streamManager.callStreamAsAnonymous(function: function, parameters: parameters),
      ifFailsAnyway: (_) {
        _listOccupiedAnonymousCommunicators.remove(thread);
        _listFreeAnonymousCommunicators.add(thread);
      },
    );

    return stream.doOnDone(() {
      _listOccupiedAnonymousCommunicators.remove(thread);
      if (!_listFreeAnonymousCommunicators.contains(thread)) {
        _listFreeAnonymousCommunicators.add(thread);
      }
    }).doOnCancel(() {
      _listOccupiedAnonymousCommunicators.remove(thread);
      if (!_listFreeAnonymousCommunicators.contains(thread)) {
        _listFreeAnonymousCommunicators.add(thread);
      }
    });
  }

  @override
  Future<IThreadCommunication> createAnonymousThread({required String name, required List<IThreadInitializer> initializers}) async {
    final thread = await _newThreadsSynchronizer.execute(function: () => createAnonymousManagerAccordingImplementation(name: name, initializers: initializers));
    listAnonymousCommunicatios.add(thread);

    return thread;
  }

  @override
  Future<void> mountEntity<T>({required T entity, bool ifExistsOmit = true}) async {
    checkProgrammingFailure(thatChecks: () => 'The entity type is not dynamic (T != dynamic)', result: () => T != dynamic);
    final existing = mapConnectionsEntity[T];

    if (existing != null) {
      if (ifExistsOmit) {
        return;
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.invalidFunctionality,
          message: '${tr('The entity ')} $T ${tr(' was mounted previously')}',
        );
      }
    }

    await createEntitysManager<T>(item: entity, initializers: threadInitializer, checkIfExists: false);
  }

  @override
  Future<IThreadCommunication> createEntitysManager<T>({required T item, required List<IThreadInitializer> initializers, bool checkIfExists = true}) async {
    if (checkIfExists) {
      final existing = mapConnectionsEntity[T];
      if (existing != null) {
        throw NegativeResult(
          identifier: NegativeResultCodes.invalidFunctionality,
          message: '${tr('The entity ')} $T ${tr(' was created previously. There cannot be two entities of the same type mounted.')}',
        );
      }
    }

    final thread = await _newThreadsSynchronizer.execute(function: () => createEntitysManagerAccordingImplementation(item: item, initializers: initializers));

    mapConnectionsEntity[T] = thread;
    return thread;
  }

  @override
  void reactConnectionClose(IThreadCommunication closedCommunicator) {
    for (final item in mapConnectionsEntity.entries) {
      if (item.value == closedCommunicator) {
        mapConnectionsEntity.remove(item.key);
        return;
      }
    }

    listAnonymousCommunicatios.remove(closedCommunicator);
    _listOccupiedAnonymousCommunicators.remove(closedCommunicator);
    _listFreeAnonymousCommunicators.remove(closedCommunicator);
  }

  @override
  Future<IThreadCommunication> searchEntityManager<T>() async {
    final existing = mapConnectionsEntity[T];

    if (existing != null) {
      return existing;
    }

    throw NegativeResult(
      identifier: NegativeResultCodes.contextInvalidFunctionality,
      message: '${tr('The entity ')} $T ${tr(' was not mounted previously.')}',
    );
  }

  @override
  Future<R> callFunctionOnTheServer<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationParameters p1) function}) {
    return function(parameters);
  }

  Future<IThreadCommunication> _reserveBackgroundThread() => _newBackgroudThreadsSynchronizer.execute(function: _reserveBackgroundThreadSecured);

  Future<IThreadCommunication> _reserveBackgroundThreadSecured() async {
    if (_listFreeAnonymousCommunicators.isNotEmpty) {
      final free = _listFreeAnonymousCommunicators.removeAt(0);
      _listOccupiedAnonymousCommunicators.add(free);
      return free;
    }

    final newThread = await createAnonymousThread(name: 'Background Thread #${listAnonymousBackgroundCommunicatios.length + 1}', initializers: threadInitializer);
    listAnonymousCommunicatios.add(newThread);
    listAnonymousBackgroundCommunicatios.add(newThread);
    _listOccupiedAnonymousCommunicators.add(newThread);
    return newThread;
  }
}
