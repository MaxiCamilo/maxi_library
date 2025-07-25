import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

mixin IPerceptiveVariable<T> on IDisposable {
  T get value;
  Stream<T> get notifyChange;
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
