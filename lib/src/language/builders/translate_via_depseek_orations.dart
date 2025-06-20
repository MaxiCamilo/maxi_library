import 'package:deepseek/deepseek.dart';
import 'package:maxi_library/maxi_library.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

class TranslateViaDepseekOrations with TextableFunctionality<Map<Oration, String>> {
  final String apiKey;
  final String languaje;
  final List<Oration> texts;
  final bool useReasoner;
  final int splitTexts;

  final String? contentText;

  static const String _standarContentText = '''
You are assuming the role of translator.
You will receive an XML file from the user. This file contains a root tag called "texts" which will contain several "text" tags, each containing text in English.
Your job is to translate the text contained in the "text" tags into %1. Return the same XML file, but with the translator texts. It must provide a natural and accurate translation; do not add comments.
''';

  const TranslateViaDepseekOrations({
    required this.apiKey,
    required this.languaje,
    required this.texts,
    this.useReasoner = true,
    this.splitTexts = 100,
    this.contentText,
  });

  @override
  Future<Map<Oration, String>> runFunctionality({required InteractiveFunctionalityExecutor<Oration, Map<Oration, String>> manager}) async {
    final result = <Oration, String>{};

    final context = (contentText ?? _standarContentText).replaceAll('%1', languaje);
    final deepSeek = DeepSeek(apiKey);

    int translatedAmount = 0;
    for (final part in texts.splitIntoParts(splitTexts)) {
      final formatedParts = part.map(
          (x) => '\t<text>${x.message.replaceAll('<', '%&1%').replaceAll('>', '%&2%').replaceAll('\n', '%&3%').replaceAll('\\n', '%&3%').replaceAll('\'', '%&4%').replaceAll('"', '%&5%').replaceAll('\\', '')}</text>');
      manager.sendItem(Oration(message: 'Deepseek is being asked to translate %1 texts (%2/%3)', textParts: [formatedParts.length, translatedAmount, texts.length]));
      if (part.any((x) => x.message.contains('\\'))) {
        print('Heyyyyyyy');
      }
      final body = '<texts>${formatedParts.join('\n')}</texts>';
      await FileOperatorMask(isLocal: true, rawRoute: 'sending.xml').writeText(content: body);
      final rawResponse = await deepSeek.createChat(
        messages: [
          Message(
            role: 'system',
            content: context,
          ),
          Message(role: 'user', content: body),
        ],
        model: 'deepseek-chat',
        /*
        options: {
          "temperature": 1.0,
          "max_tokens": 4096,
        },*/
      );

      final rawXml = rawResponse.textUtf8.replaceAll('@<', '@APERTURE@').replaceAll('@>', '@CLOSE@');

      await FileOperatorMask(isLocal: true, rawRoute: 'prueba.xml').writeText(content: rawXml);

      final document = XmlDocument.parse(rawXml);
      final splitText = document.xpath('/texts/text').map((x) => x.innerText.replaceAll('%&1%', '<').replaceAll('%&2%', '>').replaceAll('%&3%', '\\n').replaceAll('%&4%', '\'').replaceAll('%&5%', '"')).toList();

      try {
        checkProgrammingFailure(thatChecks: Oration(message: 'The same number of texts were returned'), result: () => splitText.length == part.length);
      } catch (_) {
        rethrow;
      }
      result.addAll(part.mapWithPosition((x, i) => MapEntry(x, splitText[i])).toMap());
      translatedAmount += part.length;
    }

    return result;
  }
}
