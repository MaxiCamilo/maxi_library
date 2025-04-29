import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tools/internal/shared_values_service.dart';

class IsolatedEvent<T> with StartableFunctionality, IChannel<T, T> {
  final String name;

  StreamController<T>? _controller;
  StreamSubscription<(int, T)>? _subscription;
  Completer<IsolatedEvent<T>>? _doneCompleter;

  @override
  bool get isActive => isInitialized;

  @override
  Stream<T> get receiver {
    if (_controller == null || _controller!.isClosed) {
      _controller = StreamController<T>.broadcast();
    }

    initialize();

    return _controller!.stream;
  }

  IsolatedEvent({required this.name});

  static Future<void> sendEvent({required String name, required dynamic value}) async {
    await SharedValuesService.mountService();

    await ThreadManager.callEntityFunction<SharedValuesService, void>(
      parameters: InvocationParameters.list([name, ThreadManager.instance.threadID, value]),
      function: (serv, para) => serv.setEvent(name: para.firts<String>(), threadID: para.second<int>(), value: para.third()),
    );
  }

  static Future<void> sendEventError({required String name, required dynamic value, StackTrace? stackTrace}) async {
    await SharedValuesService.mountService();

    await ThreadManager.callEntityFunction<SharedValuesService, void>(
      parameters: InvocationParameters.list([name, value, stackTrace, ThreadManager.instance.threadID]),
      function: (serv, para) => serv.setErrorEvent(name: para.firts<String>(), value: para.second(), stackTrace: para.third(), threadID: para.fourth<int>()),
    );
  }

  Future<Stream<T>> get receiverAsync async {
    await initialize();
    return _controller!.stream;
  }

  Future<StreamSubscription<T>> createStreamDirect({required void Function(T) onData, Function? onError, void Function()? onDone, bool? cancelOnError}) async {
    final stream = await receiverAsync;
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
    final stream = await receiverAsync;

    if (doOnCancel != null) {
      return stream.where(whereFunction).doOnCancel(doOnCancel).listen(onData, cancelOnError: cancelOnError, onDone: onDone, onError: onError);
    } else {
      return stream.where(whereFunction).listen(onData, cancelOnError: cancelOnError, onDone: onDone, onError: onError);
    }
  }

  @override
  Future<void> initializeFunctionality() async {
    await SharedValuesService.mountService();

    final subscription = await ThreadManager.callEntityStream<SharedValuesService, (int, T)>(
      parameters: InvocationParameters.only(name),
      function: _initializeFunctionalityOnService<T>,
    );
    _subscription = subscription.listen(_dataChanged, onError: _dataError);

    if (_controller == null || _controller!.isClosed) {
      _controller = StreamController<T>.broadcast();
    }
  }

  static Future<Stream<(int, T)>> _initializeFunctionalityOnService<T>(SharedValuesService serv, InvocationParameters para) {
    return serv.getEvent<T>(name: para.firts<String>());
  }

  @override
  Future<void> close() async {
    if (!isInitialized) {
      return;
    }
    _subscription?.cancel();
    _controller?.close();

    _controller = null;

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
    if (newValue is! (int, T)) {
      log('[IsolatedEvent] Cannot accept value of type $T');
      return;
    }

    if (newValue.$1 == ThreadManager.instance.threadID) {
      return;
    }

    _controller?.add(newValue.$2);
  }

  void _dataError(dynamic error, StackTrace? trace) {
    if (error is (int, dynamic)) {
      if (error.$1 == ThreadManager.instance.threadID) {
        return;
      }
      _controller?.addError(error.$2, trace);
    } else {
      log('[IsolatedEvent] Cannot sent Thread ID on error');
    }
  }

  @override
  Future get done {
    _doneCompleter ??= Completer<IsolatedEvent<T>>();
    return _doneCompleter!.future;
  }

  @override
  Future<void> add(T event) async {
    await initialize();

    _controller?.add(event);

    await sendEvent(name: name, value: event);
  }

  @override
  Future addStream(Stream<T> stream) async {
    await initialize();

    return await super.addStream(stream);
  }

  @override
  Future<void> addError(Object error, [StackTrace? stackTrace]) async {
    await initialize();

    _controller?.addError(error);

    sendEventError(name: name, value: error, stackTrace: stackTrace);
  }
}
