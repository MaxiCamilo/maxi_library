import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/language/xml/bundle_translated_text_file_xml.dart';

class LanguageOperatorXml with StartableFunctionality, IOperatorLanguage {
  @override
  Stream<String> get notifyLanguageChange => _notifyLanguageChangeController.stream;

  @override
  String prefixLanguage;
  final List<IReadOnlyFileOperator> includeFiles;

  late final List<BundleTranslatedTextFileXml> bundles;

  bool _inEnglish = true;
  Map<String, String> _referencesByToker = {};
  Map<String, String> _referencesByText = {};

  late final StreamController<String> _notifyLanguageChangeController;

  LanguageOperatorXml({this.prefixLanguage = 'en' /*, this.filesLocation = '${DirectoryUtilities.prefixRouteLocal}/lang',*/, this.includeFiles = const []}) {
    _notifyLanguageChangeController = StreamController<String>.broadcast();

    bundles = includeFiles.map((x) => BundleTranslatedTextFileXml(file: x)).toList(growable: false);
  }

  @override
  Future<void> changeLanguage(String newPrefixLanguage) async {
    dispose();
    await continueOtherFutures();

    prefixLanguage = newPrefixLanguage;
    await initializeFunctionality();
  }

  @override
  Future<void> initializeFunctionality() async {
    prefixLanguage = prefixLanguage.toLowerCase();

    _inEnglish = prefixLanguage == 'en';
    if (_inEnglish) {
      _referencesByToker.clear();
      _referencesByText.clear();
      _notifyLanguageChangeController.addIfActive(prefixLanguage);
      return;
    }

    final bundle = bundles.selectItem((x) => x.prefixLanguage == prefixLanguage);
    if (bundle == null) {
      log('[LanguageOperatorXml] The "$prefixLanguage" prefix was not assigned');
      _inEnglish = true;
      _referencesByToker.clear();
      _referencesByText.clear();
      _notifyLanguageChangeController.addIfActive('en');
      return;
    }

    //HACER ESTA PARTE EN SEGUNDO PLANO!
    final result = await bundle.readTranslatedText();

    _referencesByText = result.map((x, y) => MapEntry(x.message, y));
    _referencesByToker = result.entries.where((x) => x.key.tokenId.isNotEmpty).map((x) => MapEntry(x.key.tokenId, x.value)).toMap();

    _notifyLanguageChangeController.addIfActive(prefixLanguage);
  }

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

    return text.message;
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
