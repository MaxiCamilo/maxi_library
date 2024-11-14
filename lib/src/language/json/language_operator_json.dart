import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';

class LanguageOperatorJson with StartableFunctionality, IOperatorLanguage {
  @override
  Stream get notifyLanguageChange => notifyLanguageChangeController.stream;

  @override
  final String prefixLanguage;

  final String filesLocation;

  late final String realFilesLocations;
  late final StreamController notifyLanguageChangeController;

  bool inEnglish = true;

  LanguageOperatorJson({this.prefixLanguage = 'en', this.filesLocation = '${DirectoryUtilities.prefixRouteLocal}/lang'}) {
    realFilesLocations = DirectoryUtilities.interpretPrefix(filesLocation);
    notifyLanguageChangeController = StreamController.broadcast();
  }

  @override
  Future<void> initializeFunctionality() async {}

  @override
  Future<void> changeLanguage(String newPrefixLanguage) async {
    newPrefixLanguage = newPrefixLanguage.toLowerCase();

    inEnglish = newPrefixLanguage == 'en';
  }

  @override
  String translateText(TranslatableText text) {
    if (inEnglish) {
      return text.toString();
    }

    if (isInitialized) {
      return text.toString();
    } else {
      log('[LanguageOperatorJson] You must initialize the language operator!');
      return text.toString();
    }
  }
}
