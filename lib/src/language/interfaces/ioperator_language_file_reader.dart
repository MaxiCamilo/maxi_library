import 'package:maxi_library/src/language/interfaces/ibundle_translated_text.dart';

mixin IOperatorLanguajeFileReader {
  Future<bool> isFileCompatible(String fileDirection);

  Future<IBundleTranslatedText> generateBundleTranslated(String fileDirection);
}
