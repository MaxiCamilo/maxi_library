import 'package:maxi_library/maxi_library.dart';

class TypeGeneratorReflection with IReflectionType, IValueGenerator {
  final IValueGenerator generator;

  @override
  List get annotations => const [];

  @override
  Type get type {
    if (generator is IReflectionType) {
      return (generator as IReflectionType).type;
    }
    return dynamic;
  }

  @override
  String get name {
    if (generator is IReflectionType) {
      return (generator as IReflectionType).name;
    }
    return 'Adapter of generator "${generator.runtimeType}"';
  }

  const TypeGeneratorReflection({required this.generator});

  @override
  bool isTypeCompatible(Type type) {
    return generator.isTypeCompatible(type);
  }

  @override
  cloneObject(originalItem) {
    return generator.cloneObject(originalItem);
  }

  @override
  bool isCompatible(item) {
    return generator.isCompatible(item);
  }

  @override
  convertObject(originalItem) {
    return generator.convertObject(originalItem);
  }

  @override
  generateEmptryObject() {
    return generator.generateEmptryObject();
  }

  @override
  serializeToMap(item) {
    if (generator is IPrimitiveValueGenerator) {
      return (generator as IPrimitiveValueGenerator).convertToPrimitiveValue(item);
    }

    final newItme = convertObject(item);
    final classItem = ReflectionManager.getReflectionType(newItme.runtimeType, annotations: []);
    return classItem.serializeToMap(newItme);
  }

  @override
  TranslatableText get description => TranslatableText.empty;
}
