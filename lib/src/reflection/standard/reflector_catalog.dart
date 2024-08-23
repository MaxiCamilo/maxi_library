import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/standard/type_entity_reflector.dart';

abstract class ReflectorsCatalog with IThreadInitializer {
  List<ReflectorInstance> get instances;

  bool get includeInGeneratedThreads => true;

  const ReflectorsCatalog();

  void initializeReflectable() {
    if (ReflectionManager.isInitialized) {
      return;
    }

    try {
      instances.first.instanceClass.annotatedClasses;
      return;
    } catch (_) {
      for (final item in instances) {
        containErrorLog(detail: 'Reflector initialized failed', function: () => item.initializeReflectableFunction());
      }
    }

    for (final instance in instances) {
      for (var x in instance.instanceClass.annotatedClasses) {
        addMirror(instance.instanceClass, x);
      }
    }

    if (includeInGeneratedThreads) {
      ThreadManager.addThreadInitializer(initializer: this);
    }

    ReflectionManager.isInitialized = true;
  }

  void addMirror(Reflectable instance, ClassMirror mirror) {
    if (mirror.isEnum) {
      final enumAdapter = generateEnum(mirror);
      ReflectionManager.instance.enumerators.add(enumAdapter);
    } else {
      final classAdapter = TypeEntityReflector(reflectable: instance, classMirror: mirror);
      ReflectionManager.instance.entities.add(classAdapter);
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

  @override
  Future<void> performInitializationInThread(IThreadCommunicationMethod channel) async {
    initializeReflectable();
  }
}
