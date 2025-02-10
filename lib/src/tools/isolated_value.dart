import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tools/internal/shared_values_service.dart';

class IsolatedValue<T extends Object> with StartableFunctionality {
  static bool _serviceInitialized = false;

  final String name;
  final bool synchronized;

  late T _item;
  late StreamController<T> _streamChanged;

  StreamSubscription? _subscription;

  Stream<T> get changed => _streamChanged.stream;

  bool _gettingValue = false;

  IsolatedValue({
    required this.name,
    required this.synchronized,
  });

  T get localValue {
    checkInitialize();

    if (!synchronized) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: Oration(message: 'Isolated pointer is not synchronized'),
      );
    }

    if (_gettingValue) {
      return _item;
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: Oration(message: 'The value of the service must be obtained first'),
      );
    }
  }

  Future<T> get value async {
    if (synchronized) {
      await initialize();
      return _item;
    } else {
      return await ThreadManager.callEntityFunction<SharedValuesService, T>(
        parameters: InvocationParameters.only(name),
        function: (serv, para) => serv.getValue<T>(name: para.firts<String>()),
      );
    }
  }

  Future<void> changeValue({required T item}) async {
    await initialize();
    await Future.delayed(Duration.zero);
    await ThreadManager.callEntityFunction<SharedValuesService, void>(
      parameters: InvocationParameters.list([name, item]),
      function: (serv, para) => serv.setValue(name: para.firts<String>(), value: para.second()),
    );
    _gettingValue = true;
    _item = item;
  }

  @override
  Future<void> initializeFunctionality() async {
    _streamChanged = StreamController<T>.broadcast();

    if (!_serviceInitialized) {
      await _mountService();
      _serviceInitialized = true;
    }

    final subscription = await ThreadManager.callEntityStream<SharedValuesService, dynamic>(
      parameters: InvocationParameters.only(name),
      function: (serv, para) => serv.getModValueStream(name: para.firts<String>()),
    );
    _subscription = subscription.listen(_dataChanged);

    if (synchronized) {
      final value = await ThreadManager.callEntityFunction<SharedValuesService, T?>(
        parameters: InvocationParameters.only(name),
        function: _getOptionalValue<T>, //(serv, para) => serv.getOptionalValue<T>(name: para.firts<String>()),
      );

      if (value != null) {
        _item = value;
        _gettingValue = true;
      }
    }
  }

  static Future<T?> _getOptionalValue<T>(SharedValuesService serv, InvocationParameters para) async {
    return serv.getOptionalValue<T>(name: para.firts<String>());
  }

  Future<void> _mountService() async {
    await ThreadManager.mountEntity<SharedValuesService>(entity: SharedValuesService());
    _serviceInitialized = true;
  }

  void _dataChanged(dynamic newValue) {
    if (newValue is! T) {
      log('[IsolatedValue] Cannot accept value of type $T');
      return;
    }

    if (synchronized) {
      _item = newValue;
      _gettingValue = true;
    }

    _streamChanged.add(newValue);
  }

  void discard() {
    _subscription?.cancel();
    _subscription = null;

    _streamChanged.close();

    dispose();
  }
}
