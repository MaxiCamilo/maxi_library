import 'package:maxi_library/maxi_library.dart';

mixin IReflectorAlbum {
  List<ITypeEntityReflection> getReflectedEntities();
  List<TypeEnumeratorReflector> getReflectedEnums();
}
