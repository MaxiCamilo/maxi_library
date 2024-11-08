import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tools/internal/shared_values_service.dart';

class IsolatedEvent<T extends Object> with StartableFunctionality {
  static bool _serviceInitialized = false;

  final String name;

  late StreamController<T> _controller;
  StreamSubscription? _subscription;

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

  static Future<void> sendEventError({required String name, required dynamic value}) async {
    if (!_serviceInitialized) {
      await _mountService();
    }

    await ThreadManager.callEntityFunction<SharedValuesService, void>(
      parameters: InvocationParameters.list([name, value]),
      function: (serv, para) => serv.setErrorEvent(name: para.firts<String>(), value: para.second()),
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

  @override
  Future<void> initializeFunctionality() async {
    if (!_serviceInitialized) {
      await _mountService();
    }

    final subscription = await ThreadManager.callEntityStream<SharedValuesService, dynamic>(
      parameters: InvocationParameters.only(name),
      function: (serv, para) => serv.getModValueStream(name: para.firts<String>()),
    );
    _subscription = subscription.listen(_dataChanged, onError: _dataError);

    _controller = StreamController<T>.broadcast();
  }

  

  void close() {
    if (!isInitialized) {
      return;
    }
    _subscription?.cancel();
    _controller.close();

    declareDeinitialized();
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
}
