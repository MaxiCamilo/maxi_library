import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/types/type_enumerator_reflector.dart';
import 'package:reflectable/reflectable.dart';

mixin InitializeClassReflector {
  List<void Function()> get initializeReflectableFunctions;

  List<Reflectable> get instances;

  void initializeReflectable() {
    try {
      instances.first.annotatedClasses;
      return;
    } catch (_) {
      initializeReflectableFunctions.map((x) => containErrorLog(detail: 'Reflector initialized failed', function: x));
    }

    for (final instance in instances) {
      instance.annotatedClasses.map((x) => addMirror(instance, x));
    }
  }

  void addMirror(Reflectable instance, ClassMirror mirror) {
    if (mirror.isEnum) {
      final enumAdapter = generateEnum(mirror);
      ReflectionManager.instance.enumerators.add(enumAdapter);
    }
  }

  TypeEnumeratorReflector generateEnum(ClassMirror mirror) {
    final optionsList = <Enum>[];
    for (final valor in mirror.staticMembers.entries) {
      final nombre = valor.key;
      final instancia = mirror.invokeGetter(nombre);
      if (instancia is Enum) {
        optionsList.add(instancia);
      }
    }

    return TypeEnumeratorReflector(
      annotations: mirror.metadata,
      name: mirror.simpleName,
      optionsList: optionsList,
      type: mirror.dynamicReflectedType,
    );
  }
}
