import 'package:reflectable/reflectable.dart';

abstract class BaseDecoratorReflector extends Reflectable {
  const BaseDecoratorReflector()
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
