import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';

class TranslationXmlFileCreator with IStreamFunctionality<void> {
  final IFileModifierOperator fileOperator;
  final String prefix;
  final Map<Oration, String> texts;

  const TranslationXmlFileCreator({required this.fileOperator, required this.texts, required this.prefix});

  @override
  StreamStateTexts<void> runFunctionality({required FunctionalityStreamManager<void> manager}) async* {
    yield streamTextStatus(const Oration(message: 'Creating file'));
    if (await fileOperator.existsFile()) {
      await fileOperator.deleteFile();
    }

    await fileOperator.createAsFile(secured: false);
    await fileOperator.addText(content: '<?xml version="1.0" encoding="UTF-8"?>\n<translations prefix="$prefix">\n', encoder: utf8);

    for (final part in texts.entries.splitIntoParts(500)) {
      final buffer = StringBuffer();

      for (final text in part) {
        if (text.key.tokenId.isEmpty) {
          buffer.write('\t<translation>\n');
        } else {
          buffer.write('\t<translation id="${text.key.tokenId}">\n');
        }

        buffer.write('\t\t<msg>${_formatText(text.key.message)}</msg>\n');
        buffer.write('\t\t<tr>${_formatText(text.value)}</tr>\n');

        buffer.write('\t</translation>\n');
      }

      await fileOperator.addText(content: buffer.toString(), encoder: utf8);
    }

    await fileOperator.addText(content: '</translations>\n', encoder: utf8);
    yield streamTextStatus(Oration(message: 'The XML file was created in %1', textParts: [fileOperator.directAddress]));
  }

  static String _formatText(String text) {
    return text.replaceAll('<', '\$#{1}').replaceAll('>', '\$#{2}').replaceAll('\\n', '\$#{3}').replaceAll('\'', '\$#{4}').replaceAll('"', '\$#{5}').replaceAll('&', '\$#{6}');
  }
}
