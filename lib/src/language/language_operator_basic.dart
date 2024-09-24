import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';

class LanguageOperatorBasic with StartableFunctionality, IOperatorLanguage {
  final _streamController = StreamController.broadcast();

  @override
  String get prefixLanguage => 'en';

  @override
  Stream get notifyLanguageChange => _streamController.stream;

  @override
  Future<void> initializeFunctionality() async {}

  @override
  Future<void> changeLanguage(String newPrefixLanguage) async {
    log('[LanguageOperatorBasic] WARNING! A language operator has not been assigned, so only English text will be displayed');
  }

  @override
  String translateText(TranslatableText text) {
    return text.toString();
  }
}
