import 'package:maxi_library/src/language.dart';
import 'package:maxi_library/src/utilities/extension/extensions_iterators.dart';

class FormalName {
  final TranslatableText name;

  const FormalName(this.name);

  static TranslatableText searchFormalName({required TranslatableText realName, required List annotations}) {
    final formal = annotations.selectByType<FormalName>();
    if (formal != null) {
      return formal.name;
    }

    return realName;
  }
}
