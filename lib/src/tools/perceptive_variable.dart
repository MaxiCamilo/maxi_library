import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

mixin IPerceptiveVariable<T> on IDisposable {
  T get value;
  Stream<T> get notifyChange;
}

class PerceptiveVariableReference<T> with StartableFunctionality, PaternalFunctionality, IPerceptiveVariable<T> {
  final FutureOr<T> Function() valueGetter;
  final Stream<T> received;

  late final StreamController<T> _receivedController;
  late T _value;

  PerceptiveVariableReference({required this.valueGetter, required this.received});

  @override
  Future<void> initializeFunctionality() async {
    _value = await valueGetter();
    joinEvent(
      event: received,
      onData: (x) {
        _value = x;
        _receivedController.add(x);
      },
      onDone: dispose,
    );

    _receivedController = createEventController<T>(isBroadcast: true);
  }

  @override
  Stream<T> get notifyChange async* {
    await initialize();
    yield* _receivedController.stream;
  }

  @override
  T get value => checkFirstIfInitialized(() => _value);

  Future<T> get asyncValue async {
    if (isInitialized) {
      final item = await valueGetter();
      _value = item;
      return item;
    } else {
      await initialize();
      return _value;
    }
  }
}

class PerceptiveVariableOperator<T> with IDisposable, PaternalFunctionality, IPerceptiveVariable<T> {
  late T _value;
  late StreamController<T> _detector;

  @override
  T get value => _value;

  @override
  Stream<T> get notifyChange => checkFirstIfDispose(() => _detector.stream);

  set value(T newValue) {
    checkIfDispose();
    _value = value;
    _detector.add(newValue);
  }

  PerceptiveVariableOperator(T value) {
    _value = value;
    _detector = createEventController<T>(isBroadcast: true);
  }
}
