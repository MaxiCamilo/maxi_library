import 'package:maxi_library/maxi_library.dart';

class AsynchronousSingleton<T> {
  T? _value;
  final _semaphore = Semaphore();

  final Future<T> Function() initializer;
  AsynchronousSingleton({required this.initializer});

  Future<T> get value async {
    if (_value == null) {
      await _semaphore.execute(function: () async {
        if (_value != null) {
          return;
        }
        _value = await initializer();
      });
    }

    return _value!;
  }

  T get valueSync {
    if (_value == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.uninitializedFunctionality,
        message: tr('This value must be initialized asynchronously before it can be used'),
      );
    }
    return _value!;
  }
}
