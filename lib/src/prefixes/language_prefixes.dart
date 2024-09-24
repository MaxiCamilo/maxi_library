import 'package:maxi_library/maxi_library.dart';

TranslatableText tr(String part, [List parts = const []]) {
  return TranslatableText(message: part, textParts: parts);
}


