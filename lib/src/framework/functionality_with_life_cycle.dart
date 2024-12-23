import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:meta/meta.dart';

mixin FunctionalityWithLifeCycle on StartableFunctionality {
  final _streamControllers = <StreamController>[];
  final _streamSubscriptions = <StreamSubscription>[];

  Completer? _onDone;

  bool _isDispose = false;

  @protected
  Future<void> afterInitializingFunctionality();

  void dispose() => declareDeinitialized();

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

    _onDone?.completeIfIncomplete(this);
    _onDone = null;
  }

  @override
  void declareDeinitialized() {
    if (!isInitialized) {
      return;
    }
    super.declareDeinitialized();
    _removeJoinedObjects();
    _isDispose = true;
  }

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

    if (_isDispose) {
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
