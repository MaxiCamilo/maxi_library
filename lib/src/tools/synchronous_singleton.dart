class SynchronousSingleton<T> {
  T? _value;

  final T Function() initializer;
  SynchronousSingleton({required this.initializer});

  T get value {
    _value ??= initializer();
    return _value!;
  }
}
