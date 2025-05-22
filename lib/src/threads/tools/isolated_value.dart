import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tools/internal/shared_values_service.dart';

class IsolatedValue<T extends Object> with StartableFunctionality, PaternalFunctionality ,FunctionalityWithLifeCycle, IChannel<T, T> {
  final String name;
  final T? defaultValue;

  T? _actualItem;

  late IChannel<T, T> _channel;
  late StreamController<T> _receiverController;

  Completer? _waiterDone;

  @override
  bool get isActive => isInitialized;

  @override
  Stream<T> get receiver => checkFirstIfInitialized(() => _receiverController.stream);

  bool get isDefined => _actualItem != null;

  IsolatedValue({required this.name, this.defaultValue});

  static Future<T?> getValueFromThread<T>({required String name}) => ThreadManager.callEntityFunction<SharedValuesService, T?>(
        parameters: InvocationParameters.only(name),
        function: _getValueStatic<T>,
      );

  static Future<void> changeValueFromThread<T>({required String name, required T? value}) => ThreadManager.callEntityFunction<SharedValuesService, void>(
        parameters: InvocationParameters.list([name, value]),
        function: (serv, para) => serv.changeValue(valueName: para.firts<String>(), value: para.second<T?>()),
      );

  @override
  Future<void> afterInitializingFunctionality() async {
    await SharedValuesService.mountService();
    _actualItem = null;
    _channel = await joinAsyncObject(
      () => ThreadManager.createEntityChannel<SharedValuesService, T, T>(
        parameters: InvocationParameters.only(name),
        function: _createChannel<T>,
      ),
    );

    _channel.receiver.listen((x) {
      _actualItem = x;
      _receiverController.addIfActive(x);
    });

    _actualItem = await ThreadManager.callEntityFunction<SharedValuesService, T?>(
      parameters: InvocationParameters.only(name),
      function: _getValueStatic<T>,
    );

    if (_actualItem == null && defaultValue != null) {
      _channel.add(defaultValue!);
      _actualItem = defaultValue;
    }
//
    _receiverController = createEventController<T>(isBroadcast: true);
  }

  Future<void> changeValue(T value) async {
    await initialize();

    //_receiverController.addIfActive(value);

    _channel.add(value);
    _actualItem = value;
    await continueOtherFutures();
  }

  T get syncValue {
    return checkFirstIfInitialized(() {
      if (_actualItem == null) {
        throw NegativeResult(
          identifier: NegativeResultCodes.nullValue,
          message: Oration(message: 'A value to the shared variable %1 was not yet defined', textParts: [name]),
        );
      } else {
        return _actualItem!;
      }
    });
  }

  Future<T> get asyncValue async {
    await initialize();

    _actualItem = await ThreadManager.callEntityFunction<SharedValuesService, T?>(
      parameters: InvocationParameters.only(name),
      function: _getValueStatic<T>,
    );

    if (_actualItem == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nullValue,
        message: Oration(message: 'A value to the shared variable %1 was not yet defined', textParts: [name]),
      );
    } else {
      return _actualItem!;
    }
  }

  @override
  void add(T event) {
    changeValue(event);
  }

  @override
  Future addStream(Stream<T> stream) async {
    await initialize();
    return await super.addStream(stream);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future close() async {
    dispose();
  }

  @override
  Future get done {
    _waiterDone ??= MaxiCompleter();
    return _waiterDone!.future;
  }

  @override
  void dispose() {
    _actualItem = null;
    _waiterDone?.completeIfIncomplete();
    _waiterDone = null;
    super.dispose();
  }

  static FutureOr<void> _createChannel<T>(SharedValuesService entity, InvocationContext context, IChannel<T, T> channel) async {
    await entity.indexChannelOfValues<T>(valueName: context.firts<String>(), channel: channel);
  }

  static FutureOr<T?> _getValueStatic<T>(SharedValuesService entity, InvocationParameters context) {
    return entity.getValue(context.firts());
  }
}
