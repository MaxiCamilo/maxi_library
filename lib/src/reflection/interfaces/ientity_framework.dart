import 'package:maxi_library/src/reflection/interfaces/igetter_reflector.dart';

mixin IEntityFramework {
  bool get hasPrimaryKey;

  IGetterReflector get primaryKey;

  int getPrimaryKey({required instance});

  void changePrimaryKey({required instance, required int newId});

  dynamic interpretation({
    required dynamic value,
    bool enableCustomInterpretation = true,
    bool verify = true,
  });
}
