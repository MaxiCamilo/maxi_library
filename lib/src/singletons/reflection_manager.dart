import 'dart:collection';

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

  static ITypeEntityReflection getReflectionEntity(Type type) {
    final item = getEntities().selectItem((x) => x.type == type);
    if (item == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: tr('There is no entity reflector for type %1', [type]),
      );
    }

    return item;
  }

  static ITypeEntityReflection getReflectionEntityByName(String name) {
    final item = getEntities().selectItem((x) => x.name == name);
    if (item == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: tr('An entity named %1 was not found', [name]),
      );
    }

    return item;
  }

  static ITypeEntityReflection? tryGetReflectionEntity(Type type) {
    return instance._entities.selectItem((x) => x.type == type);
  }

  @override
  Future<void> performInitializationInThread(IThreadManager channel) async {
    _instance = this;
  }

  static List serializeList({required List list, bool setTypeValue = true}) {
    final mapList = [];
    ITypeEntityReflection? lastReflector;
    Type? lastType;

    for (final item in list) {
      if (lastType == null || item.runtimeType != lastType) {
        lastType = item.runtimeType;
        lastReflector = getReflectionEntity(item.runtimeType);
      }

      final result = lastReflector!.serializeToMap(item);

      if (setTypeValue && result is Map<String, dynamic>) {
        result['\$type'] = item.runtimeType.toString();
      }

      mapList.add(result);
    }

    return mapList;
  }

  static String serializeJson({required dynamic value, bool setTypeValue = true}) {
    if (value == null) {
      return 'null';
    } else if (value is List) {
      return serializeListToJson(list: value, setTypeValue: setTypeValue);
    } else if (value is Enum) {
      return value.index.toString();
    }

    if (ReflectionUtilities.isPrimitive(value.runtimeType) != null) {
      return ReflectionUtilities.serializeToJson(value);
    }

    final entity = getReflectionEntity(value.runtimeType);
    return entity.serializeToJson(value: value);
  }

  static String serializeListToJson({required List list, bool setTypeValue = true}) {
    final jsonList = <String>[];
    ITypeEntityReflection? lastReflector;
    Type? lastType;

    for (final item in list) {
      if (lastType == null || item.runtimeType != lastType) {
        lastType = item.runtimeType;
        lastReflector = getReflectionEntity(item.runtimeType);
      }

      jsonList.add(lastReflector!.serializeToJson(value: item, setTypeValue: setTypeValue));
    }

    return '[${TextUtilities.generateCommand(list: jsonList)}]';
  }

  static int getIdentifier(dynamic item) {
    return getReflectionEntity(item.runtimeType).getPrimaryKey(instance: item);
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

  static List<T> orderListByIdentifier<T>({required Iterable<T> list}) {
    return mapByIdentifier(list: list).values.cast<T>().toList();
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
}
