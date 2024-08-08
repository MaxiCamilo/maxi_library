import 'package:maxi_library/maxi_library.dart';
import 'package:reflectable/reflectable.dart';

import 'reflectors_generated.dart' as reflectable;
import 'reflectors_generated.reflectable.dart' as generated;

class InstanceReflectionTest extends InstancesReflection {
  @override
  List<void Function()> get initializeReflectableFunctions => [generated.initializeReflectable];

  @override
  List<Reflectable> get instances => [reflectable.reflector];
}
