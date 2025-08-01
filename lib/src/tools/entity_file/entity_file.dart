import 'dart:async';
import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';

class EntityFile<T> with StartableFunctionality, IPerceptiveVariable<T> {
  final IFileOperator _address;
  final _saveSyncronous = Semaphore();

  int? maxSize;
  T? _item;

  late final ITypeEntityReflection _reflected;

  final _changeEvent = StreamController<T>.broadcast();

  @override
  Stream<T> get notifyChange => _changeEvent.stream;

  EntityFile({
    required IFileOperator address,
    T? item,
    this.maxSize,
  })  : _item = item,
        _address = address {
    _reflected = ReflectionManager.getReflectionEntity(T);
  }

  @override
  T get value {
    if (_item == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.uninitializedFunctionality,
        message: Oration(message: 'File not uploaded'),
      );
    } else {
      return _item!;
    }
  }

  Future<void> loadFile() {
    return _saveSyncronous.execute(function: () async {
      await _address.createAsFile(secured: true);

      final rawContent = await _address.readTextual(maxSize: maxSize);

      final newValue = (_reflected.interpretationFromJson(rawJson: rawContent, tryToCorrectNames: true) as T);

      //_reflected.verifyValueDirectly(value: newValue, parentEntity: null);

      _item = newValue;
      _changeEvent.add(newValue);
    });
  }

  Future<void> saveFile() {
    return _saveSyncronous.execute(function: () {
      final contentJson = json.encode(_reflected.serializeToMap(value));
      return _address.writeText(content: contentJson);
    });
  }

  Future<void> changeFile({required T newValue}) {
    _item = newValue;
    return saveFile();
  }

  @override
  Future<void> initializeFunctionality() async {
    final roFolder = _address.getContainingFolder();

    final folder = programmingFailure(reasonFailure: const Oration(message: 'The Director Operator must return a modifiable operator'), function: () => roFolder as IFileModifierOperator);

    await folder.createAsFolder(secured: true);

    if (await _address.existsFile()) {
      await loadFile();
    } else {
      _item ??= _reflected.generateEmptryObject();

      await saveFile();
    }
  }
}
