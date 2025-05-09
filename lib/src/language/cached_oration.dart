import 'package:maxi_library/maxi_library.dart';

class CachedOration extends Oration {
  String? _lastResult;
  String _lastLeng = '';

  factory CachedOration.translate({required Oration text}) {
    return CachedOration(message: text.message, textParts: text.textParts, tokenId: text.tokenId);
  }

  factory CachedOration.interpretFromJson({required String text}) {
    return CachedOration.translate(text: Oration.interpretFromJson(text: text));
  }

  CachedOration({required super.message, super.textParts, super.tokenId});

  @override
  String toString() {
    if ((_lastLeng != LanguageManager.instance.prefixLanguage) || _lastResult == null) {
      _updateText();
    }

    return _lastResult!;
  }

  void _updateText() {
    _lastLeng = LanguageManager.instance.prefixLanguage;
    _lastResult = LanguageManager.translateText(Oration(message: message, textParts: textParts, tokenId: tokenId));
  }
}
