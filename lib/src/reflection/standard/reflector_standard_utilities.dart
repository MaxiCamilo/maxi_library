import 'package:maxi_library/maxi_library.dart';
import 'package:reflectable/reflectable.dart';

mixin ReflectorStandardUtilities {
  static ObjectMirror getStaticInstance({required Reflectable reflect, required Type type}) {
    return volatile(
      detail: () => trc('The type %1 is not reflect (and is not ObjectMirror)', [type]),
      function: () => reflect.reflectType(type) as ObjectMirror,
    );
  }

  static ObjectMirror getInstance({required Reflectable reflect, required dynamic object}) {
    return reflect.reflect(object);
  }
}
