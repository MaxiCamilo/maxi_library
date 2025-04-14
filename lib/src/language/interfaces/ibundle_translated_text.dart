import 'package:maxi_library/maxi_library.dart';

mixin IBundleTranslatedText { 

  String get prefixLanguage;

  Future<Map<Oration, String>> readTranslatedText();
}
