mixin IBundleTranslatedText { 

  String get prefixLanguage;

  Future<Map<String, String>> readTranslatedText();
}
