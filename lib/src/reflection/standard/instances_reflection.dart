import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/standard/type_entity_reflector.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_communication_method.dart';
import 'package:reflectable/reflectable.dart';

abstract class InstancesReflection with IThreadInitializer {
  List<void Function()> get initializeReflectableFunctions;

  List<Reflectable> get instances;

  bool get includeInGeneratedThreads => true;

  const InstancesReflection();

  void initializeReflectable() {
    if (ReflectionManager.isInitialized) {
      return;
    }

    try {
      instances.first.annotatedClasses;
      return;
    } catch (_) {
      for (final item in initializeReflectableFunctions) {
        containErrorLog(detail: 'Reflector initialized failed', function: () => item());
      }
    }

    for (final instance in instances) {
      for (var x in instance.annotatedClasses) {
        addMirror(instance, x);
      }
    }

    if (includeInGeneratedThreads) {
      ThreadManager.threadInitializers.add(this);
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
  Future<void> performInitialization(IThreadCommunicationMethod channel) async {
    initializeReflectable();
  }
}
