import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/language/interfaces/itext_traslator.dart';
import 'package:maxi_library/src/language/interfaces/itranslatable_text_locator.dart';
import 'package:maxi_library/src/language/interfaces/itranslated_text_builder.dart';

class AutomaticTranslationGenerator {
  final String prefix;
  final ITranslatableTextLocator locator;
  final ITextTraslator translator;
  final ITranslatedTextBuilder builder;

  const AutomaticTranslationGenerator({required this.prefix, required this.locator, required this.translator, required this.builder});

  Future<void> start() async {
    log('-> ${Oration(message: 'Searching texts')}');
    final texts = await locator.searchTranslatableText();

    log('└-> ${Oration(message: '%1 translatable texts were found', textParts:[texts.length])}');
    if (texts.isEmpty) {
      return;
    }

    log('-> ${Oration(message: 'Translating %1 texts', textParts:[texts.length])}');

    final translatingTexts = <String, String>{};
    int i = 1;

    for (final item in texts) {
      final newText = await translator.traslateText(item);
      log('└-> $i) "$item" = "$newText"');
      translatingTexts[item] = newText;
      i += 1;
    }

    log('-> ${Oration(message: 'Building a package of translations')}');

    await builder.generate(prefix: prefix, mapTexts: translatingTexts);

    log('-> ${Oration(message: 'Completed Construction')}');
  }
}
