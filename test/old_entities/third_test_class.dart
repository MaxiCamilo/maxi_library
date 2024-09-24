import 'package:maxi_library/maxi_library.dart';


@reflect
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
