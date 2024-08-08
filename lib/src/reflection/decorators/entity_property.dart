import 'package:maxi_library/maxi_library.dart';

class EntityProperty with IValueGenerator {
  final Type type;

  const EntityProperty({required this.type});

  @override
  cloneObject(originalItem) {
    return ReflectionManager.getReflectionEntity(type).cloneObject(originalItem);
  }

  @override
  convertObject(originalItem) {
    return ReflectionManager.getReflectionEntity(type).cloneObject(originalItem);
  }

  @override
  generateEmptryObject() {
    return ReflectionManager.getReflectionEntity(type).generateEmptryObject();
  }

  @override
  bool isCompatible(item) {
    return item.runtimeType == type;
  }

  @override
  bool isTypeCompatible(Type type) {
    return type == this.type;
  }
}
