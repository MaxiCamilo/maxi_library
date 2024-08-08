import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/types/type_generator_reflection.dart';
import 'package:maxi_library/src/reflection/types/type_void_reflection.dart';

class ReflectionManager {
  static ReflectionManager? _instance;
  // Avoid self instance
  ReflectionManager._();

  List<TypeEnumeratorReflector> enumerators = [];
  List<IReflectionType> predefinedTypes = [];
  List<ITypeEntityReflection> entities = [];

  static ITypeEntityReflection? _lastRequestedEntity;

  static bool isInitialized = false;

  static ReflectionManager get instance => _instance ??= ReflectionManager._();

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

    final isPredefined = instance.predefinedTypes.selectItem((x) => x.type == type);
    if (isPredefined != null) {
      return isPredefined;
    }

    final isEntity = instance.entities.selectItem((x) => x.type == type);
    if (isEntity != null) {
      _lastRequestedEntity = isEntity;
      return isEntity;
    }

    final primitiveType = ReflectionUtilities.isPrimitive(type);
    if (primitiveType != null) {
      return TypePrimitiveReflection(annotations: [], type: type);
    }

    final isEnumerator = instance.enumerators.selectItem((x) => x.type == type);
    if (isEnumerator != null) {
      return isEnumerator;
    }

    return TypeUnknownReflection(type: type);
  }

  static ITypeEntityReflection? tryGetReflectionEntity(Type type) {
    return instance.entities.selectItem((x) => x.type == type);
  }

  static ITypeEntityReflection getReflectionEntity(Type type) {
    final item = tryGetReflectionEntity(type);
    if (item == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: trc('There is no entity reflector for type %1', [type]),
      );
    }

    return item;
  }

  static ITypeEntityReflection getReflectionEntityByName(String name) {
    final item = instance.entities.selectItem((x) => x.name == name);
    if (item == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: trc('An entity named %1 was not found', [name]),
      );
    }

    return item;
  }
}
