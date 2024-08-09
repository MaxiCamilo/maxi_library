import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/decorators/essential_key.dart';

import 'reflectors_generated.dart';

@reflector
class ThirdTestClass {
  @PrimaryKey()
  @CheckNumberRange(maximum: 999)
  int identifier = 0;

  @EssentialKey()
  @CheckTextLength(minimum: 3, maximum: 120)
  String name = '';

  bool isAdmin = false;

  @CheckNumberRange(minimum: 18, maximum: 120)
  @EssentialKey()
  int age = 0;
}
