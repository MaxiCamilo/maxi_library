import 'package:maxi_library/maxi_library.dart';

mixin IValueGenerator {
  dynamic generateEmptryObject();

  dynamic convertObject(originalItem);

  dynamic cloneObject(originalItem);

  bool isCompatible(dynamic item);

  bool isTypeCompatible(Type type);
}

mixin IPrimitiveValueGenerator on IValueGenerator {
  PrimitiesType get primitiveType;

  dynamic convertToPrimitiveValue(dynamic value);

  dynamic interpretPrimitiveValue(dynamic value);
}
