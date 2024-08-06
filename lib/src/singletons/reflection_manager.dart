import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/interfaces/ireflection_type.dart';
import 'package:maxi_library/src/reflection/interfaces/itype_entity_reflection.dart';
import 'package:maxi_library/src/reflection/types/type_enumerator_reflector.dart';
import 'package:maxi_library/src/reflection/types/type_primitive_reflection.dart';
import 'package:maxi_library/src/reflection/types/type_unknown_reflection.dart';

class ReflectionManager {
  static ReflectionManager? _instance;
  // Avoid self instance
  ReflectionManager._();

  List<TypeEnumeratorReflector> enumerators = [];
  List<IReflectionType> predefinedTypes = [];
  List<ITypeEntityReflection> entities = [];

  static ReflectionManager get instance => _instance ??= ReflectionManager._();

  static IReflectionType getReflectionType(Type type) {
    final isPredefined = instance.predefinedTypes.selectItem((x) => x.type == type);
    if (isPredefined != null) {
      return isPredefined;
    }

    final isEntity = instance.entities.selectItem((x) => x.type == type);
    if (isEntity != null) {
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

  static ITypeEntityReflection getReflectionEntity(Type type) {
    final item = instance.entities.selectItem((x) => x.type == type);
    if (item == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: trc('"There is no entity reflector for type %1', [type]),
      );
    }

    return item;
  }
}
