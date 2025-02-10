import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:maxi_library/maxi_library.dart';

class LanguageOperatorJson with StartableFunctionality, IOperatorLanguage {
  @override
  Stream get notifyLanguageChange => notifyLanguageChangeController.stream;

  @override
  String prefixLanguage;

  final String filesLocation;

  late final StreamController notifyLanguageChangeController;

  final List<BundleTranslatedTextFileJson> bundles = [];

  bool inEnglish = true;

  final _translatedTextsMaps = <String, String>{};

  LanguageOperatorJson({this.prefixLanguage = 'en', this.filesLocation = '${DirectoryUtilities.prefixRouteLocal}/lang'}) {
    notifyLanguageChangeController = StreamController.broadcast();
  }

  @override
  Future<void> initializeFunctionality() async {
    bundles.clear();
    final folderMask = FileOperatorMask(isLocal: false, rawRoute: filesLocation);
    await folderMask.initialize();
    await folderMask.createAsFolder(secured: true);
    final folder = Directory(folderMask.directAddress);

    final filesList = await folder.list(recursive: false).where((entity) => entity is File && entity.path.endsWith('.json')).toList();

    for (final item in filesList) {
      bundles.add(BundleTranslatedTextFileJson(file: FileOperatorMask(isLocal: false, rawRoute: item.path)));
    }
  }

  @override
  Future<void> changeLanguage(String newPrefixLanguage) async {
    newPrefixLanguage = newPrefixLanguage.toLowerCase();

    bool inEnglish = newPrefixLanguage == 'en';
    if (inEnglish) {
      this.inEnglish = true;
      _translatedTextsMaps.clear();
      return;
    }

    final bundle = bundles.selectItem((x) => x.prefixLanguage == newPrefixLanguage);
    if (bundle == null) {
      log('[LanguageOperatorJson] Language with prefix $newPrefixLanguage was not found');
      return;
    }

    prefixLanguage = newPrefixLanguage;

    this.inEnglish = false;
    _translatedTextsMaps.addAll(await bundle.readTranslatedText());

    notifyLanguageChangeController.add(prefixLanguage);
  }

  @override
  String translateText(Oration text) {
    if (inEnglish) {
      return _makeNewText(text.message, text);
    }

    if (isInitialized) {
      final newText = translateString(text.message);
      return _makeNewText(newText, text);
    } else {
      log('[LanguageOperatorJson] You must initialize the language operator!');
      return _makeNewText(text.message, text);
    }
  }

  String _makeNewText(String replacementText, Oration text) {
    if (text.isFixed) {
      return replacementText;
    }

    for (int i = 0; i < text.textParts.length; i++) {
      final part = text.textParts[i];
      late String textGenerated;
      if (part is TranslatedOration) {
        textGenerated = part.toString();
      }
      if (part is Oration) {
        textGenerated = translateText(part);
      } else {
        textGenerated = part.toString();
      }

      replacementText = replacementText.replaceAll('%${i + 1}', textGenerated);
    }
    return replacementText;
  }

  @override
  String translateString(String text) {
    if (inEnglish) {
      return text;
    }

    final candidate = _translatedTextsMaps[text];
    if (candidate == null) {
      log('There is no translatable candidate for text: "$text"');
      _translatedTextsMaps[text] = text;
      final bundle = bundles.selectItem((x) => x.prefixLanguage == prefixLanguage);
      if (bundle != null) {
        File(bundle.file.directAddress).writeAsStringSync(json.encode(_translatedTextsMaps));
      }
      return text;
    } else {
      return candidate;
    }
  }
}
