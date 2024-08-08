mixin IValueGenerator {
  dynamic generateEmptryObject();

  dynamic convertObject(originalItem);

  dynamic cloneObject(originalItem);

  bool isCompatible(dynamic item);

  bool isTypeCompatible(Type type);
}
