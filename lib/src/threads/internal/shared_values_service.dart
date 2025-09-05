import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/internal/isolated_shared_functionality_instance.dart';
import 'package:maxi_library/src/tools/internal/isolated_task_queue_controller.dart';

class SharedValuesService with StartableFunctionality, IThreadService {
  @override
  String get serviceName => 'Shared Events & Values';

  late final Map<String, dynamic> _mapValues;
  late final Map<String, List<IChannel>> _valueChannels;
  //late final StreamController<(String, dynamic)> _streamEvents;
  late final Map<String, StreamController> _streamControllers;

  late final List<IsolatedSharedFunctionalityInstance> _functionalities;

  final taskQueueList = <IsolatedTaskQueueController>[];

  static bool _wasMounted = false;

  static Future<void> mountService() async {
    if (_wasMounted) {
      return;
    }

    await ThreadManager.mountEntity<SharedValuesService>(entity: SharedValuesService());
    _wasMounted = true;
  }

  @override
  Future<void> initializeFunctionality() async {
    _mapValues = SplayTreeMap<String, dynamic>();
    _streamControllers = <String, StreamController>{};
    _valueChannels = <String, List<IChannel>>{};
    _functionalities = [];
  }

  T? getOptionalValue<T>({required String name}) => _mapValues[name];
/*
  Future<T> getValue<T>({required String name}) async {
    final result = _mapValues[name];

    if (result is T) {
      return result;
    } else {
      if (result == null) {
        throw NegativeResult(
          identifier: NegativeResultCodes.nonExistent,
          message: Oration(message: 'Value %1 was not defined', textParts: [name]),
        );
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.wrongType,
          message: Oration(message: 'Value %1 is %2, but %3 was expected ', textParts: [name, result.runtimeType, T]),
        );
      }
    }
  }*/

  Future<Stream<(int, T)>> getEvent<T>({required String name}) async {
    final existent = _streamControllers[name];
    if (existent == null) {
      final newController = StreamController<(int, T)>.broadcast();
      _streamControllers[name] = newController;
      return newController.stream;
    } else {
      if (existent is StreamController<(int, T)>) {
        return existent.stream;
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.implementationFailure,
          message: Oration(
            message: 'The %1 event was initialized as %2, but it was desired with type %3',
            textParts: [name, existent.runtimeType.toString(), T.toString()],
          ),
        );
      }
    }

    //return _streamEvents.stream.where((x) => x.$1 == name).map((x) => x.$2);
  }

  Future<void> setEvent({required String name, required int threadID, required dynamic value}) async {
    final existent = _streamControllers[name];
    if (existent == null) {
      log('[SharedValueService]¡There is no $name (${value.runtimeType}) event to receive the object!');
    } else {
      existent.add((threadID, value));
    }
  }

  Future<void> setErrorEvent({required String name, required int threadID, required dynamic value, StackTrace? stackTrace}) async {
    final existent = _streamControllers[name];
    if (existent == null) {
      log('[SharedValueService]¡There is no $name (${value.runtimeType}) event to receive the error!');
    } else {
      existent.addError((threadID, value));
    }
  }

  T? getValue<T>(String name) {
    final value = _mapValues[name];

    if (value == null) {
      return null;
    }

    if (value is T) {
      return value;
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(
          message: 'The shared value %1 is expected to be %2, but the value is %3',
          textParts: [name, T, value.runtimeType],
        ),
      );
    }
  }

  void changeValue<T>({required String valueName, required T value /*, IChannel? omitChannel*/}) {
    _mapValues[valueName] = value;

    final channelList = _valueChannels[valueName];
    if (channelList != null) {
      for (final channel in channelList) {
        /*
        if (omitChannel == channel) {
          continue;
        }*/
        try {
          channel.add(value);
        } catch (ex) {
          log('[SharedValuesService] The channel rejected value: "$ex"');
        }
      }
    }
  }

  Future<void> indexChannelOfValues<T>({required String valueName, required IChannel<T, T> channel}) async {
    final actualValue = _mapValues[valueName];
    if (actualValue != null && actualValue is! T) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(message: 'Actually, the type of value of %1 is %2, but it was expected to be %3', textParts: [valueName, actualValue.runtimeType, T]),
      );
    }

    if (!_valueChannels.containsKey(valueName)) {
      _valueChannels[valueName] = <IChannel>[];
    }

    final list = _valueChannels[valueName]!;
    list.add(channel);

    channel.done.whenComplete(() => list.remove(channel));
    channel.receiver.listen((x) => changeValue<T>(value: x, valueName: valueName /*, omitChannel: channel*/));
  }

  IsolatedTaskQueueController getTaskQueue(String name) {
    final exists = taskQueueList.selectItem((x) => x.nameQueue == name);
    if (exists == null) {
      final newController = IsolatedTaskQueueController(nameQueue: name);
      taskQueueList.add(newController);
      return newController;
    } else {
      return exists;
    }
  }

  bool existsFunctionality<I, R>({required String name, bool failIfItsAnotherType = true}) {
    final func = _functionalities.selectItem((x) => x.name == name);
    if (func == null) {
      return false;
    } else if (func is IsolatedSharedFunctionalityInstance<I, R>) {
      return true;
    } else if (failIfItsAnotherType) {
      throw NegativeResult(
          identifier: NegativeResultCodes.wrongType,
          message: Oration(
            message: 'Functionality begins with another type of return (%1 y %2)',
            textParts: [I, R],
          ));
    } else {
      return false;
    }
  }

  IsolatedSharedFunctionalityInstance<I, R> getFunctionality<I, R>({required String name}) {
    final func = _functionalities.selectRequiredItem(
        (x) => x.name == name,
        Oration(
          message: 'The shared functionality %1 has not been defined yet',
          textParts: [name],
        ));
    if (func is IsolatedSharedFunctionalityInstance<I, R>) {
      return func;
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(
          message: 'The shared functionality %1 is of type (%2,%3), but you were trying to change it to a functionality of type (%4,%5), which is not compatible',
          textParts: [name, func.functionality.itemType, func.functionality.resultType, I, R],
        ),
      );
    }
  }

  Future<void> defineOrChangeSharedFunctionality<I, R>({
    required String name,
    required InteractiveFunctionality<I, R> functionality,
    bool omitIfItsExists = true,
  }) async {
    final func = _functionalities.selectItem((x) => x.name == name);

    if (func == null) {
      _functionalities.add(IsolatedSharedFunctionalityInstance<I, R>(name: name, functionality: functionality));
    } else {
      if (omitIfItsExists) {
        return;
      }

      if (func.functionality == functionality) {
        return;
      }

      if (func is! IsolatedSharedFunctionalityInstance<I, R>) {
        throw NegativeResult(
          identifier: NegativeResultCodes.wrongType,
          message: Oration(
            message: 'The shared functionality %1 is of type (%2,%3), but you were trying to change it to a functionality of type (%4,%5), which is not compatible',
            textParts: [name, func.functionality.itemType, func.functionality.resultType, functionality.itemType, functionality.resultType],
          ),
        );
      }

      await func.changeFunctionality(newFunctionality: functionality);
    }
  }
}
