import 'package:maxi_library/maxi_library.dart';

mixin IReflectionType {
  List get annotations;

  Type get type;

  String get name;

  Oration get description;

  bool isCompatible(dynamic item);

  bool isTypeCompatible(Type type);

  dynamic generateEmptryObject();

  dynamic convertObject(dynamic originalItem);

  dynamic cloneObject(dynamic originalItem);

  dynamic serializeToMap(dynamic item);
}
