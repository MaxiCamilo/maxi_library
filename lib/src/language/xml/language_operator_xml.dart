import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';

class LanguageOperatorXml with StartableFunctionality, PaternalFunctionality, FunctionalityWithLifeCycle, IOperatorLanguage {
  @override
  String prefixLanguage;
  final List<IReadOnlyFileOperator> includeFiles;

  late final List<BundleTranslatedTextFileXml> bundles;

  bool _inEnglish = true;
  Map<String, String> _referencesByToker = {};
  Map<String, String> _referencesByText = {};

  LanguageOperatorXml({this.prefixLanguage = 'en' /*, this.filesLocation = '${DirectoryUtilities.prefixRouteLocal}/lang',*/, this.includeFiles = const []}) {
    bundles = includeFiles.map((x) => BundleTranslatedTextFileXml(file: x)).toList(growable: false);
  }

  @override
  Future<void> changeLanguage(String newPrefixLanguage) async {
    await initialize();
    if (prefixLanguage == newPrefixLanguage) {
      return;
    } else {
      prefixLanguage = newPrefixLanguage;
      await _updateTexts();
    }
  }

  @override
  Future<void> afterInitializingFunctionality() async {
    prefixLanguage = prefixLanguage.toLowerCase();

    await LanguageManager.notifyLanguageChangeOperator.initialize();
    await _updateTexts();

    joinEvent(event: LanguageManager.notifyLanguageChangeOperator.receiver, onData: changeLanguage);
  }

  Future<void> _updateTexts() async {
    _inEnglish = prefixLanguage == 'en';
    if (_inEnglish) {
      _referencesByToker.clear();
      _referencesByText.clear();
      LanguageManager.notifyLanguageChangeOperator.addIfActive(prefixLanguage);
      return;
    }

    final bundle = bundles.selectItem((x) => x.prefixLanguage == prefixLanguage);
    if (bundle == null) {
      log('[LanguageOperatorXml] The "$prefixLanguage" prefix was not assigned');
      _inEnglish = true;
      _referencesByToker.clear();
      _referencesByText.clear();
      LanguageManager.notifyLanguageChangeOperator.addIfActive('en');
      return;
    }

    //final result = await bundle.readTranslatedText();
    final result = await bundle.readTranslatedText();

    _referencesByText = result.map((x, y) => MapEntry(x.message, y));
    _referencesByToker = result.entries.where((x) => x.key.tokenId.isNotEmpty).map((x) => MapEntry(x.key.tokenId, x.value)).toMap();

    LanguageManager.notifyLanguageChangeOperator.addIfActive(prefixLanguage);
  }

  /*static Future<Map<Oration, String>> _readTranslatedText(InvocationContext context) {
    final item = context.firts<BundleTranslatedTextFileXml>();
    return item.readTranslatedText();
  }*/

  @override
  String translateString(String text) {
    if (_inEnglish) {
      return text;
    }

    final textByText = _referencesByText[text];
    if (textByText != null) {
      return text;
    }

    final otherText = _referencesByText[text.replaceAll('\n', '\\n')];
    if (otherText != null) {
      return otherText.replaceAll('\\n', '\n');
    }

    log('[LanguageOperatorXml] Text "$text" has no translation');

    return text;
  }

  @override
  String translateText(Oration text) {
    if (_inEnglish) {
      return text.message;
    }

    if (!isInitialized) {
      log('[LanguageOperatorXml] The operator was not initialized!');
      return text.message;
    }

    final textByToken = _referencesByToker[text.tokenId];
    if (textByToken != null) {
      return _makeNewText(textByToken, text);
    }

    final textByText = _referencesByText[text.message];
    if (textByText != null) {
      return _makeNewText(textByText, text);
    }

    final otherText = _referencesByText[text.message.replaceAll('\n', '\\n')];
    if (otherText != null) {
      return _makeNewText(otherText.replaceAll('\\n', '\n'), text);
    }

    if (text.tokenId.isEmpty) {
      log('[LanguageOperatorXml] Oration with text "${text.message}" has no translation');
    } else {
      log('[LanguageOperatorXml] Oration with Token "${text.tokenId}" has no translation');
    }

    return _makeNewText(text.message, text);
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
}
