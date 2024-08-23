import 'package:maxi_library/maxi_library.dart';

import 'reflectors_generated.dart' as reflectable;
import 'reflectors_generated.reflectable.dart' as generated;

class InstanceReflectionTest extends ReflectorsCatalog {
  @override
  List<ReflectorInstance> get instances => const [
        ReflectorInstance(
          initializeReflectableFunction: generated.initializeReflectable,
          instanceClass: reflectable.reflector,
        )
      ];
}
