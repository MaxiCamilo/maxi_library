import 'dart:collection';

mixin IBundleTranslatedText { 

  String get prefixLanguage;

  Future<SplayTreeMap<String, String>> readTRanslatedText();
}
