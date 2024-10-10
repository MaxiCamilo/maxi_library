import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:maxi_library/maxi_library.dart';

class EntityFile<T> with StartableFunctionality {
  final String _address;
  final _saveSyncronous = Semaphore();

  int? maxSize;
  T? _item;

  late final IReflectionType _reflected;

  final _changeEvent = StreamController<T>.broadcast();

  Stream<T> get changeItem => _changeEvent.stream;

  EntityFile({
    required String address,
    T? item,
    this.maxSize,
  })  : _item = item,
        _address = DirectoryUtilities.interpretPrefix(address) {
    _reflected = ReflectionManager.getReflectionType(T);
  }

  T get item {
    if (_item == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.uninitializedFunctionality,
        message: tr('File not uploaded'),
      );
    } else {
      return _item!;
    }
  }

  Future<void> loadFile() {
    return _saveSyncronous.execute(function: () async {
      await DirectoryUtilities.createFile(_address);

      final rawContent = await DirectoryUtilities.readTextualFile(fileDirection: _address, maxSize: maxSize);

      final newValue = (_reflected.convertObject(rawContent) as T);

      if (_reflected is ITypeEntityReflection) {
        _reflected.verifyValueDirectly(value: newValue, parentEntity: null);
      }

      _item = newValue;
      _changeEvent.add(newValue);
    });
  }

  Future<void> saveFile() {
    return _saveSyncronous.execute(function: () {
      final contentJson = json.encode(_reflected.serializeToMap(item));
      return DirectoryUtilities.writeTextFile(fileDirection: _address, content: contentJson);
    });
  }

  Future<void> changeFile({required T newValue}) {
    _item = newValue;
    return saveFile();
  }

  @override
  Future<void> initializeFunctionality() async {
    if (_item == null) {
      if (await File(_address).exists()) {
        await loadFile();
      } else {
        _item = _reflected.generateEmptryObject();
        await saveFile();
      }
    } else {
      final folder = DirectoryUtilities.extractFileLocation(fileDirection: _address);
      await DirectoryUtilities.createFolder(folder);
    }
  }
}
