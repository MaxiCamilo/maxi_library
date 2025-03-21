import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:meta/meta.dart';

mixin FunctionalityWithLifeCycle on StartableFunctionality {
  final _streamControllers = <StreamController>[];
  final _streamSubscriptions = <StreamSubscription>[];
  final _waiters = <Completer>[];
  final _otherActiveList = <Object>[];

  Completer? _onDone;

  @protected
  Future<void> afterInitializingFunctionality();

  Future get done {
    _onDone ??= Completer();

    return _onDone!.future;
  }

  @override
  @protected
  Future<void> initializeFunctionality() async {
    try {
      await afterInitializingFunctionality();
    } catch (ex) {
      _onDone?.completeErrorIfIncomplete(ex);
      _onDone = null;
      _removeJoinedObjects();
      rethrow;
    }
  }

  void _removeJoinedObjects() {
    _streamControllers.iterar((x) => x.close());
    _streamSubscriptions.iterar((x) => x.cancel());

    _streamControllers.clear();
    _streamSubscriptions.clear();

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
        log('[FunctionalityWithLifeCycle] Error stirring the united object: $ex');
      }
    });
    _otherActiveList.clear();

    _onDone?.completeIfIncomplete(this);
    _onDone = null;
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

  @override
  @mustCallSuper
  void performObjectDiscard() {
    if (!isInitialized) {
      return;
    }
    super.performObjectDiscard();
    _removeJoinedObjects();
    afterDiscard();
  }

  @protected
  void afterDiscard() {}

  StreamController<R> createEventController<R>({required bool isBroadcast}) {
    late final StreamController<R> newController;

    if (isBroadcast) {
      newController = StreamController<R>.broadcast();
    } else {
      newController = StreamController<R>();
    }

    _streamControllers.add(newController);
    newController.done.whenComplete(() => _streamControllers.remove(newController));

    return newController;
  }

  StreamSubscription<T> joinSubscription<T>(StreamSubscription<T> subscription) {
    _streamSubscriptions.add(subscription);
    return subscription;
  }

  Completer<R> joinWaiter<R>([Completer<R>? waiter]) {
    waiter ??= Completer<R>();
    checkProgrammingFailure(thatChecks: const Oration(message: 'The waiter was already completed'), result: () => !waiter!.isCompleted);

    _waiters.add(waiter);
    waiter.future.whenComplete(() => _waiters.remove(waiter));
    return waiter;
  }

  StreamSubscription<R> joinEvent<R>({
    required Stream<R> event,
    required void Function(R) onData,
    void Function(dynamic)? onError,
    void Function()? onDone,
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

    return subscription;
  }
/*
  R joinObject<R extends Object>({required R item}) {
    _otherActiveList.add(item);
    return item;
  }*/

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
}
