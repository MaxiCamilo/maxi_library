import 'dart:collection';
import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/types/type_generator_reflection.dart';
import 'package:maxi_library/src/reflection/types/type_void_reflection.dart';

class ReflectionManager with IThreadInitializer {
  static ReflectionManager? _instance;
  // Avoid self instance
  ReflectionManager._();

  final List<IReflectorAlbum> _albums = [];
  final List<TypeEnumeratorReflector> _enumerators = [];
  final List<IReflectionType> _predefinedTypes = [];
  final List<ITypeEntityReflection> _entities = [];

  bool _openedAlbums = false;

  static ITypeEntityReflection? _lastRequestedEntity;

  static set defineAlbums(List<IReflectorAlbum> list) {
    instance._albums.addAll(list);
    //instance.enumerators.addAll(list.expand((x) => x.getReflectedEnums()));

    final listGenerators = instance._albums.expand((x) => x.getReflectedList()).toList();
    instance._enumerators.addAll(instance._albums.expand((x) => x.getReflectedEnums()));
    instance._predefinedTypes.addAll(listGenerators);
  }

  static void defineAsTheMainReflector() {
    ThreadManager.addThreadInitializer(initializer: instance);
  }

  static ReflectionManager get instance => _instance ??= ReflectionManager._();

  static List<ITypeEntityReflection> getEntities() {
    _openAlbums();
    return instance._entities;
  }

  static TypeEnumeratorReflector? tryGetEnumReflector(Type type) {
    return instance._enumerators.selectItem((x) => x.type == type);
  }

  static IValueGenerator getValuesAdapter(Type type, {List annotations = const []}) {
    final exists = tryGetValuesAdapter(type, annotations: annotations);

    if (exists == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: tr('There is no value reflector adapter for type %1', [type]),
      );
    }

    return exists;
  }

  static IValueGenerator? tryGetValuesAdapter(Type type, {List annotations = const []}) {
    final generator = annotations.selectByType<IValueGenerator>();
    if (generator != null) {
      return generator;
    }

    final isPrimitive = ReflectionUtilities.isPrimitive(type);
    if (isPrimitive != null) {
      return TypePrimitiveReflection(annotations: annotations, type: type);
    }

    final isEnum = instance._enumerators.selectItem((x) => x.type == type);
    if (isEnum != null) {
      return isEnum;
    }

    final isPredefine = instance._predefinedTypes.selectItem((x) => x is IValueGenerator && x.type == type);
    if (isPredefine != null) {
      return isPredefine as IValueGenerator;
    }

    return null;
  }

  static IPrimitiveValueGenerator getPrimitiveAdapter(Type type, {List annotations = const []}) {
    final exists = tryGetPrimitiveAdapter(type, annotations: annotations);

    if (exists == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: tr('There is no primitive reflector adapter for type %1', [type]),
      );
    }

    return exists;
  }

  static IPrimitiveValueGenerator? tryGetPrimitiveAdapter(Type type, {List annotations = const []}) {
    final generator = annotations.selectByType<IPrimitiveValueGenerator>();
    if (generator != null) {
      return generator;
    }

    final isPrimitive = ReflectionUtilities.isPrimitive(type);
    if (isPrimitive != null) {
      return TypePrimitiveReflection(annotations: annotations, type: type);
    }

    final isEnum = instance._enumerators.selectItem((x) => x.type == type);
    if (isEnum != null) {
      return isEnum;
    }

    final isPredefine = instance._predefinedTypes.selectItem((x) => x is IPrimitiveValueGenerator && x.type == type);
    if (isPredefine != null) {
      return isPredefine as IPrimitiveValueGenerator;
    }

    return null;
  }

  static IReflectionType getReflectionType(Type type, {List annotations = const []}) {
    final generator = annotations.selectByType<IValueGenerator>();
    if (generator != null) {
      return TypeGeneratorReflection(generator: generator);
    }

    if (_lastRequestedEntity != null && _lastRequestedEntity!.type == type) {
      return _lastRequestedEntity!;
    }

    if (type == dynamic || type == Never) {
      return const TypeDynamicReflection();
    }

    if (type.toString() == 'void') {
      return const TypeVoidReflection();
    }

    final primitiveType = ReflectionUtilities.isPrimitive(type);
    if (primitiveType != null) {
      return TypePrimitiveReflection(annotations: [], type: type);
    }

    final isPredefined = instance._predefinedTypes.selectItem((x) => x.type == type);
    if (isPredefined != null) {
      return isPredefined;
    }

    final isEnum = instance._enumerators.selectItem((x) => x.type == type);
    if (isEnum != null) {
      return isEnum;
    }

    _openAlbums();

    final isEntity = instance._entities.selectItem((x) => x.type == type);
    if (isEntity != null) {
      _lastRequestedEntity = isEntity;
      return isEntity;
    }

    return TypeUnknownReflection(type: type);
  }

  static void _openAlbums() {
    if (instance._openedAlbums) {
      return;
    }

    final entities = instance._albums.expand((x) => x.getReflectedEntities()).toList();
    //final enums = instance.albums.expand((x) => x.getReflectedEnums()).toList();

    instance._openedAlbums = true;
    instance._entities.addAll(entities);
  }

  static ITypeEntityReflection? tryGetReflectionEntity(Type type) {
    if (_lastRequestedEntity != null && _lastRequestedEntity!.type == type) {
      return _lastRequestedEntity!;
    }

    return getEntities().selectItem((x) => x.type == type);
  }

  static ITypeEntityReflection getReflectionEntity(Type type) {
    if (_lastRequestedEntity != null && _lastRequestedEntity!.type == type) {
      return _lastRequestedEntity!;
    }

    final item = getEntities().selectItem((x) => x.type == type);
    if (item == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: tr('There is no entity reflector for type %1', [type]),
      );
    }

    _lastRequestedEntity = item;
    return item;
  }

  static ITypeEntityReflection getReflectionEntityByName(String name) {
    if (_lastRequestedEntity != null && _lastRequestedEntity!.name == name) {
      return _lastRequestedEntity!;
    }

    final item = getEntities().selectItem((x) => x.name == name);
    if (item == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: tr('An entity named %1 was not found', [name]),
      );
    }

    _lastRequestedEntity = item;
    return item;
  }

  static bool compareByReflectedHashCode(Object first, Object second, [bool includeName = false]) {
    final reflectedFirst = getReflectionEntity(first.runtimeType);
    if (!reflectedFirst.isCompatible(second)) {
      return false;
    }

    final reflectedSecond = getReflectionEntity(second.runtimeType);

    return reflectedFirst.generateHashCode(item: first, addName: includeName) == reflectedSecond.generateHashCode(item: second, addName: includeName);
  }

  @override
  Future<void> performInitializationInThread(IThreadManager channel) async {
    _instance = this;
  }

  static String serialzeEntityToJson({required dynamic value, bool setTypeValue = true}) {
    checkProgrammingFailure(thatChecks: tr('Value must not be  null'), result: () => value != null);
    final valueOperator = getReflectionEntity(value.runtimeType);
    return valueOperator.serializeToJson(value: value, setTypeValue: setTypeValue);
  }

  static String serializeListToJson({required dynamic value, bool setTypeValue = true}) {
    if (value == null) {
      return 'null';
    }

    if (value is! List) {
      if (ReflectionUtilities.isPrimitive(value.runtimeType) != null) {
        return value.runtimeType == String ? '["${value.toString()}"]' : '[${value.toString()}]';
      } else {
        return '[${getReflectionEntity(value.runtimeType).serializeToJson(value: value, setTypeValue: setTypeValue)}]';
      }
    }

    final jsonList = <String>[];
    ITypeEntityReflection? lastReflector;
    Type? lastType;

    for (final item in value) {
      if (item is List) {
        jsonList.add(serializeListToJson(value: item, setTypeValue: setTypeValue));
      } else if (item is Enum || ReflectionUtilities.isPrimitive(item.runtimeType) != null) {
        jsonList.add(ReflectionUtilities.serializeToJson(item));
      } else if (item is ICustomSerialization) {
        final customSer = item.serialize();
        if (customSer is String) {
          jsonList.add(customSer);
        } else if (customSer is Map<String, dynamic>) {
          jsonList.add(json.encode(customSer));
        } else {
          throw NegativeResult(identifier: NegativeResultCodes.wrongType, message: tr('Custom serialization returned an object of type %1, but it is not convertible to json', [customSer.runtimeType]));
        }
      } else {
        if (lastType == null || item.runtimeType != lastType) {
          lastType = item.runtimeType;
          lastReflector = getReflectionEntity(item.runtimeType);
        }

        jsonList.add(lastReflector!.serializeToJson(value: item, setTypeValue: setTypeValue));
      }
    }

    return '[${TextUtilities.generateCommand(list: jsonList)}]';
  }

  static int getIdentifier(dynamic item) {
    return getReflectionEntity(item.runtimeType).getPrimaryKey(instance: item);
  }

  static List<int> toIdentifierList<T>(Iterable<T> list, {Type? entityType, bool growable = true}) {
    final reflector = getReflectionEntity(entityType ?? T);
    return list.map((x) => reflector.getPrimaryKey(instance: x)).toList(growable: growable);
  }

  static SplayTreeMap<int, dynamic> mapByIdentifier({required Iterable list}) {
    final map = SplayTreeMap<int, dynamic>();
    ITypeEntityReflection? reflector;
    Type? lastType;

    for (final item in list) {
      if (reflector == null || lastType == null || lastType != item.runtimeType) {
        lastType = item.runtimeType;
        reflector = getReflectionEntity(lastType);
      }

      final id = reflector.getPrimaryKey(instance: item);
      map[id] = item;
    }

    return map;
  }

  static List<T> orderListByIdentifier<T>({required Iterable<T> list, bool reverse = false}) {
    if (reverse) {
      return mapByIdentifier(list: list).values.cast<T>().toList().reversed.toList();
    } else {
      return mapByIdentifier(list: list).values.cast<T>().toList();
    }
  }

  static bool areSame({required dynamic first, required dynamic second, List annotations = const []}) {
    if (first == null && second == null) {
      return true;
    } else if (first == null && second != null || first != null && second == null) {
      return false;
    }

    if (first.runtimeType != second.runtimeType) {
      return false;
    }

    final reflectedType = getReflectionType(first.runtimeType, annotations: annotations);

    if (reflectedType is GeneratorList) {
      return reflectedType.areSame(first: first, second: second);
    } else if (reflectedType is TypePrimitiveReflection || reflectedType is TypeEnumeratorReflector || reflectedType is TypeDynamicReflection) {
      return first == second;
    } else if (reflectedType is ITypeClassReflection) {
      return reflectedType.areSame(first: first, second: second);
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: tr('It is not possible to dynamically compare type %1', [reflectedType.type]),
      );
    }
  }

  static Object tryToInterpretFromUnknownJson({required String rawJson, required bool tryToCorrectNames}) {
    if (!rawJson.startsWith('{') || !rawJson.endsWith('}')) {
      throw NegativeResult(identifier: NegativeResultCodes.wrongType, message: tr('The JSON Objects must be enclosed in {}'));
    }

    final mapValues = volatile(detail: tr('The value received is not a valid json object'), function: () => json.encode(rawJson) as Map<String, dynamic>);

    final typeName = volatile(detail: tr('Json does not have the type signature'), function: () => mapValues['\$type']! as String);

    if (typeName == 'error' || typeName.startsWith('error.')) {
      return NegativeResult.interpret(values: mapValues, checkTypeFlag: false);
    }

    return getReflectionEntityByName(typeName).interpret(value: rawJson, tryToCorrectNames: tryToCorrectNames);
  }

  static List<Object> tryToInterpretFromUnknownJsonList({required String rawJson, required bool tryToCorrectNames}) {
    if (!rawJson.startsWith('[') || !rawJson.endsWith(']')) {
      throw NegativeResult(identifier: NegativeResultCodes.wrongType, message: tr('The JSON List must be enclosed in []'));
    }

    final newList = <Object>[];

    final rawList = volatile(detail: tr('The value received is not a valid json object'), function: () => json.encode(rawJson) as List);

    for (final value in rawList) {
      if (value.startsWith('{') && value.endsWith('}')) {
        newList.add(tryToInterpretFromUnknownJson(rawJson: rawJson, tryToCorrectNames: tryToCorrectNames));
      } else if (value.startsWith('[') && value.endsWith(']')) {
        newList.add(tryToInterpretFromUnknownJsonList(rawJson: rawJson, tryToCorrectNames: tryToCorrectNames));
      } else {
        newList.add(value);
      }
    }

    if (newList.isNotEmpty) {
      final sameType = newList.first.runtimeType;
      if (ReflectionUtilities.isPrimitive(sameType) == null || tryGetReflectionEntity(sameType) != null) {
        for (final item in newList) {
          if (item.runtimeType != sameType) {
            break;
          }
        }

        return getReflectionEntity(sameType).createList(newList) as List<Object>;
      }
    }

    return newList;
  }

  static T interpretJson<T>({
    required String rawText,
    required bool tryToCorrectNames,
    bool enableCustomInterpretation = true,
    bool verify = true,
    bool acceptZeroIdentifier = true,
    bool primaryKeyMustBePresent = true,
    bool essentialKeysMustBePresent = true,
  }) {
    return ReflectionManager.getReflectionEntity(T).interpretationFromJson(
      rawJson: rawText,
      tryToCorrectNames: tryToCorrectNames,
      enableCustomInterpretation: enableCustomInterpretation,
      verify: verify,
      acceptZeroIdentifier: acceptZeroIdentifier,
      primaryKeyMustBePresent: primaryKeyMustBePresent,
      essentialKeysMustBePresent: essentialKeysMustBePresent,
    ) as T;
  }

  static List<T> interpretJsonList<T>({
    required String rawText,
    required bool tryToCorrectNames,
    bool enableCustomInterpretation = true,
    bool verify = true,
    bool acceptZeroIdentifier = true,
    bool primaryKeyMustBePresent = true,
    bool essentialKeysMustBePresent = true,
  }) {
    return ReflectionManager.getReflectionEntity(T).interpretJsonAslist<T>(
      rawText: rawText,
      tryToCorrectNames: tryToCorrectNames,
      enableCustomInterpretation: enableCustomInterpretation,
      verify: verify,
      acceptZeroIdentifier: acceptZeroIdentifier,
      primaryKeyMustBePresent: primaryKeyMustBePresent,
      essentialKeysMustBePresent: essentialKeysMustBePresent,
    );
  }
}
