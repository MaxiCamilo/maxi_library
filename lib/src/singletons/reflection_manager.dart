import 'package:maxi_library/src/reflection/interfaces/ireflection_type.dart';

class ReflectionManager {
  static ReflectionManager? _instance;
  // Avoid self instance
  ReflectionManager._();
  static ReflectionManager get instance => _instance ??= ReflectionManager._();

  static IReflectionType getReflectionType(Type type) {}
}
