import 'package:maxi_library/src/language.dart';
import 'package:maxi_library/src/utilities/extension/extensions_iterators.dart';

class FormalName {
  final Oration name;

  const FormalName(this.name);

  static Oration searchFormalName({required Oration realName, required List annotations}) {
    final formal = annotations.selectByType<FormalName>();
    if (formal != null) {
      return formal.name;
    }

    return realName;
  }
}
