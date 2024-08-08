import 'package:maxi_library/src/utilities/extension/extensions_iterators.dart';

class FormalName {
  final String name;

  const FormalName(this.name);

  static String searchFormalName({required String realName, required List annotations}) {
    final formal = annotations.selectByType<FormalName>();
    if (formal != null) {
      return formal.name;
    }

    return realName;
  }
}
