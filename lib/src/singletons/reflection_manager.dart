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
    final item = instance._entities.selectItem((x) => x.type == type);
    if (item == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: trc('There is no entity reflector for type %1', [type]),
      );
    }

    return item;
  }

  static ITypeEntityReflection getReflectionEntityByName(String name) {
    final item = instance._entities.selectItem((x) => x.name == name);
    if (item == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: trc('An entity named %1 was not found', [name]),
      );
    }

    return item;
  }

  static ITypeEntityReflection? tryGetReflectionEntity(Type type) {
    return instance._entities.selectItem((x) => x.type == type);
  }

  @override
  Future<void> performInitializationInThread(IThreadCommunicationMethod channel) async {
    _instance = this;
  }
}
