import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/build/generators/generated_reflected_class.dart';
import 'package:maxi_library/src/reflection/entity_implementation/reflected_entity.dart';

abstract class GeneratedReflectorAlbum with IReflectorAlbum {
  const GeneratedReflectorAlbum();
  List<GeneratedReflectedClass> get classes;
  List<TypeEnumeratorReflector> get enums;

  @override
  List<ITypeEntityReflection> getReflectedEntities() => classes.map((x) => ReflectedEntity(reflectedClass: x)).toList();

  @override
  List<TypeEnumeratorReflector> getReflectedEnums() => enums;

  @override
  List<GeneratorList> getReflectedList() => classes.map((x) => x.createListGenerator()).toList();
}
