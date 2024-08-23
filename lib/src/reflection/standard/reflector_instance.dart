import 'package:maxi_library/maxi_library.dart';

class ReflectorInstance {
  final void Function() initializeReflectableFunction;
  final Reflectable instanceClass;

  const ReflectorInstance({required this.initializeReflectableFunction, required this.instanceClass});
}
