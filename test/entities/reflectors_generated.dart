import 'package:reflectable/reflectable.dart';

export 'test_class.dart';
export 'second_test_class.dart';
export 'third_test_class.dart';

class ReflectorTest extends Reflectable {
  const ReflectorTest()
      : super(
          invokingCapability,
          declarationsCapability,
          typeCapability,
          typingCapability,
          typeRelationsCapability,
          subtypeQuantifyCapability,
          reflectedTypeCapability,
        );
}

const reflector = ReflectorTest();
void main(List<String> args) {}
