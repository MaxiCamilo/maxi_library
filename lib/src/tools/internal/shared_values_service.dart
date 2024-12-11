import 'dart:async';
import 'dart:collection';

import 'package:maxi_library/maxi_library.dart';

class SharedValuesService with StartableFunctionality, IThreadService {
  @override
  String get serviceName => 'Shared Values';

  late final SplayTreeMap<String, dynamic> _mapValues;
  late final StreamController<(String, dynamic)> _streamController;
  late final StreamController<(String, dynamic)> _streamEvent;

  @override
  Future<void> initializeFunctionality() async {
    _mapValues = SplayTreeMap<String, dynamic>();
    _streamController = StreamController<(String, dynamic)>.broadcast();
    _streamEvent = StreamController<(String, dynamic)>.broadcast();
  }

  Future<T?> getOptionalValue<T>({required String name}) async => _mapValues[name];

  Future<T> getValue<T>({required String name}) async {
    final result = _mapValues[name];

    if (result is T) {
      return result;
    } else {
      if (result == null) {
        throw NegativeResult(
          identifier: NegativeResultCodes.nonExistent,
          message: tr('Value %1 was not defined', [name]),
        );
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.wrongType,
          message: tr('Value %1 is %2, but %3 was expected ', [name, result.runtimeType, T]),
        );
      }
    }
  }

  Future<void> setValue({required String name, required dynamic value}) async {
    _mapValues[name] = value;
    _streamController.add((name, value));
  }

  Future<Stream> getModValueStream({required String name}) async {
    return _streamController.stream.where((x) => x.$1 == name).map((x) => x.$2);
  }

  Future<Stream> getEvent({required String name}) async {
    return _streamEvent.stream.where((x) => x.$1 == name).map((x) => x.$2);
  }

  Future<void> setEvent({required String name, required dynamic value}) async {
    _streamEvent.add((name, value));
  }

  Future<void> setErrorEvent({required String name, required dynamic value}) async {
    _streamEvent.addError((name, value));
  }
}
