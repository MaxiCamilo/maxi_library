import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tools/internal/shared_values_service.dart';

class IsolatedEvent<T> with StartableFunctionality implements StreamSink<T> {
  static bool _serviceInitialized = false;

  final String name;

  late StreamController<T> _controller;
  StreamSubscription? _subscription;
  Completer<IsolatedEvent<T>>? _doneCompleter;

  IsolatedEvent({required this.name});

  static Future<void> sendEvent({required String name, required dynamic value}) async {
    if (!_serviceInitialized) {
      await _mountService();
    }

    await ThreadManager.callEntityFunction<SharedValuesService, void>(
      parameters: InvocationParameters.list([name, value]),
      function: (serv, para) => serv.setEvent(name: para.firts<String>(), value: para.second()),
    );
  }

  static Future<void> sendEventError({required String name, required dynamic value, StackTrace? stackTrace}) async {
    if (!_serviceInitialized) {
      await _mountService();
    }

    await ThreadManager.callEntityFunction<SharedValuesService, void>(
      parameters: InvocationParameters.list([name, value, stackTrace]),
      function: (serv, para) => serv.setErrorEvent(name: para.firts<String>(), value: para.second(), stackTrace: para.third()),
    );
  }

  Stream<T> get stream {
    checkInitialize();
    return _controller.stream;
  }

  Future<Stream<T>> get streamAsync async {
    await initialize();
    return _controller.stream;
  }

  Future<StreamSubscription<T>> createStreamDirect({required void Function(T) onData, Function? onError, void Function()? onDone, bool? cancelOnError}) async {
    final stream = await streamAsync;
    return stream.listen(onData, cancelOnError: cancelOnError, onDone: onDone, onError: onError);
  }

  Future<StreamSubscription<T>> createStreamDirectWhere({
    required bool Function(T) whereFunction,
    required void Function(T) onData,
    Function? onError,
    FutureOr<void> Function()? doOnCancel,
    void Function()? onDone,
    bool? cancelOnError,
  }) async {
    final stream = await streamAsync;

    if (doOnCancel != null) {
      return stream.where(whereFunction).doOnCancel(doOnCancel).listen(onData, cancelOnError: cancelOnError, onDone: onDone, onError: onError);
    } else {
      return stream.where(whereFunction).listen(onData, cancelOnError: cancelOnError, onDone: onDone, onError: onError);
    }
  }

  @override
  Future<void> initializeFunctionality() async {
    if (!_serviceInitialized) {
      await _mountService();
    }

    final subscription = await ThreadManager.callEntityStream<SharedValuesService, dynamic>(
      parameters: InvocationParameters.only(name),
      function: (serv, para) => serv.getEvent(name: para.firts<String>()),
    );
    _subscription = subscription.listen(_dataChanged, onError: _dataError);

    _controller = StreamController<T>.broadcast();
  }

  @override
  Future<void> close() async {
    if (!isInitialized) {
      return;
    }
    _subscription?.cancel();
    _controller.close();

    dispose();
  }

  @override
  void dispose() {
    if (_doneCompleter != null) {
      _doneCompleter!.completeIfIncomplete(this);
      _doneCompleter = null;
    }
    super.dispose();
  }

  void _dataChanged(dynamic newValue) {
    if (newValue is! T) {
      log('[IsolatedEvent] Cannot accept value of type $T');
      return;
    }

    _controller.add(newValue);
  }

  void _dataError(dynamic error, StackTrace? trace) {
    _controller.addError(error, trace);
  }

  static Future<void> _mountService() async {
    await ThreadManager.mountEntity<SharedValuesService>(entity: SharedValuesService());
    _serviceInitialized = true;
  }

  @override
  Future get done {
    _doneCompleter ??= Completer<IsolatedEvent<T>>();
    return _doneCompleter!.future;
  }

  @override
  void add(T event) {
    initialize().then((_) {
      sendEvent(name: name, value: event);
    });
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    initialize().then((_) {
      sendEventError(name: name, value: error, stackTrace: stackTrace);
    });
  }

  @override
  Future addStream(Stream<T> stream) async {
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
