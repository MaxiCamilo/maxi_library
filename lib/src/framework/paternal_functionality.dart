import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/export_reflectors.dart';
import 'package:meta/meta.dart';

mixin PaternalFunctionality on IDisposable {
  final _streamControllers = <StreamController>[];
  final _streamSubscriptions = <StreamSubscription>[];
  final _waiters = <Completer>[];
  final _otherActiveList = <Object>[];
  final _futures = <Future>[];
  final _invokeObjects = <(Object, FutureOr Function(Object))>[];

  bool get hasChildren => _streamControllers.isNotEmpty || _streamSubscriptions.isNotEmpty || _waiters.isNotEmpty || _otherActiveList.isNotEmpty || _futures.isNotEmpty || _invokeObjects.isNotEmpty;

  R invokeFunctionIfDiscarded<R extends Object>({required R item, required FutureOr Function(R) function}) {
    _invokeObjects.add((item as Object, function as FutureOr Function(Object)));
    return item;
  }

  R joinObject<R extends Object>({required R item}) {
    _otherActiveList.add(item);
    return item;
  }

  Future<R> joinAsyncObject<R extends Object>(Future<R> Function() function) async {
    final result = await function();
    _otherActiveList.add(result);
    return result;
  }

  StreamController<R> createEventController<R>({required bool isBroadcast}) {
    late final StreamController<R> newController;

    if (isBroadcast) {
      newController = StreamController<R>.broadcast();
    } else {
      newController = StreamController<R>();
    }

    return joinStreamController<R>(newController);
  }

  StreamController<R> joinStreamController<R>(StreamController<R> controller) {
    _streamControllers.add(controller);
    controller.done.whenComplete(() => _streamControllers.remove(controller));

    return controller;
  }

  StreamSubscription<T> joinSubscription<T>(StreamSubscription<T> subscription) {
    _streamSubscriptions.add(subscription);
    return subscription;
  }

  Future<T> joinFuture<T>(
    Future<T> future, {
    void Function(T)? onDone,
    void Function(Object, StackTrace)? onError,
    void Function()? whenCompleted,
  }) async {
    try {
      _futures.add(future);
      final result = await future;
      if (onDone != null) {
        onDone(result);
      }
      return result;
    } catch (ex, st) {
      if (onError != null) {
        onError(ex, st);
      }
      rethrow;
    } finally {
      _futures.remove(future);
      if (whenCompleted != null) {
        whenCompleted();
      }
    }
  }

  Completer<R> joinWaiter<R>([Completer<R>? waiter]) {
    waiter ??= MaxiCompleter<R>();
    checkProgrammingFailure(thatChecks: const Oration(message: 'The waiter was already completed'), result: () => !waiter!.isCompleted);

    _waiters.add(waiter);
    waiter.future.whenComplete(() {
      _waiters.remove(waiter);
    });
    return waiter;
  }

  StreamSubscription<R> joinEvent<R>({
    required Stream<R> event,
    required void Function(R) onData,
    void Function(dynamic)? onError,
    void Function()? onDone,
    Function(StreamSubscription)? onSubscriptionCreated,
  }) {
    late final StreamSubscription<R> subscription;
    subscription = event.listen(
      onData,
      onError: onError,
      onDone: () {
        _streamSubscriptions.remove(subscription);
        if (onDone != null) {
          onDone();
        }
      },
    );
    _streamSubscriptions.add(subscription);

    if (onSubscriptionCreated != null) {
      onSubscriptionCreated(subscription);
    }

    return subscription;
  }

  Future<StreamSubscription<R>> callEntityStreamDirectly<S extends Object, R>({
    InvocationParameters parameters = InvocationParameters.emptry,
    required FutureOr<Stream<R>> Function(S serv, InvocationParameters para) function,
    bool cancelOnError = false,
    void Function(R)? onListen,
    void Function()? onDone,
    void Function(Object error, [StackTrace? stackTrace])? onError,
  }) async {
    final subscription = await ThreadManager.callEntityStreamDirectly(
      function: function,
      cancelOnError: cancelOnError,
      onDone: onDone,
      onError: onError,
      onListen: onListen,
      parameters: parameters,
    );

    if (wasDiscarded) {
      subscription.cancel();
    } else {
      _streamSubscriptions.add(subscription);
    }

    return subscription;
  }

  Future<StreamController<R>> createEntityControllerStream<S extends Object, R>({
    required bool isBroadcast,
    required FutureOr<Stream<R>> Function(S serv, InvocationParameters para) function,
    InvocationParameters parameters = InvocationParameters.emptry,
    bool cancelOnError = false,
    void Function(R)? onListen,
    void Function()? onDone,
    void Function(Object error, [StackTrace? stackTrace])? onError,
  }) async {
    final controller = createEventController<R>(isBroadcast: isBroadcast);

    final subscription = await callEntityStreamDirectly(
      function: function,
      parameters: parameters,
      cancelOnError: cancelOnError,
      onListen: (x) {
        controller.addIfActive(x);
        if (onListen != null) {
          onListen(x);
        }
      },
      onError: (x, [y]) {
        controller.addErrorIfActive(x, y);
        if (onError != null) {
          onError(x, y);
        }
      },
      onDone: () {
        controller.close();
        if (onDone != null) {
          onDone();
        }
      },
    );

    controller.done.whenComplete(() => subscription.cancel());

    return controller;
  }

  @override
  @mustCallSuper
  void performObjectDiscard() {
    removeJoinedObjects();
  }

  @protected
  @mustCallSuper
  void removeJoinedObjects() {
    _streamControllers.iterar((x) => x.close());
    _streamSubscriptions.iterar((x) => x.cancel());

    _streamControllers.clear();
    _streamSubscriptions.clear();

    _futures.iterar((x) => x.ignore());
    _futures.clear();

    _waiters.iterar((x) {
      x.completeErrorIfIncomplete(
        NegativeResult(
          identifier: NegativeResultCodes.functionalityCancelled,
          message: const Oration(message: 'The functionality was canceled'),
        ),
      );
    });

    _waiters.clear();

    _otherActiveList.iterar((x) {
      try {
        (x as dynamic).dispose();
      } catch (ex) {
        log('[PaternalFunctionality] Error stirring the united object: $ex');
      }
    });
    _otherActiveList.clear();

    _invokeObjects.iterar((x) {
      try {
        x.$2(x.$1);
      } catch (ex) {
        log('[PaternalFunctionality] Error by invoking a function for a discharge object: $ex');
      }
    });

    _invokeObjects.clear();
  }
}
