import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/language/interfaces/ibundle_translated_text.dart';
import 'package:xml/xml.dart';

class BundleTranslatedTextFileXml with IBundleTranslatedText {
  final IReadOnlyFileOperator file;

  @override
  late final String prefixLanguage;

  BundleTranslatedTextFileXml({required this.file}) {
    prefixLanguage = DirectoryUtilities.extractFileName(route: file.directAddress, includeExtension: false);
  }

  @override
  Future<Map<Oration, String>> readTranslatedText() async {
    final contentFile = await file.readTextual(maxSize: 35000024);
    return await ThreadManager.callBackgroundFunction(function: _transformXML, parameters: InvocationParameters.list([prefixLanguage, contentFile]));
  }

  static Future<Map<Oration, String>> _transformXML(InvocationContext context) async {
    final prefixLanguage = context.firts<String>();
    final contentFile = context.second<String>();

    final result = <Oration, String>{};
    final document = XmlDocument.parse(contentFile);
    final root = document.rootElement;

    final prefixLanguageInFile = volatile(detail: const Oration(message: 'The language prefix must be defined'), function: () => root.getAttribute('prefix')!);

    if (prefixLanguageInFile.toLowerCase() != prefixLanguage.toLowerCase()) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidValue,
        message: Oration(
          message: 'The file says it has the prefix %1, but the file is named %2',
          textParts: [prefixLanguageInFile, prefixLanguage],
        ),
      );
    }

    final translations = root.findElements('translation');

    for (var t in translations) {
      final msg = _formatText(t.getElement('msg', namespace: '*')?.innerText ?? '');
      final tr = _formatText(t.getElement('tr', namespace: '*')?.innerText ?? '');
      final id = _formatText(t.getAttribute('id') ?? '');

      result[Oration(message: msg, tokenId: id)] = tr;
    }

    return result;
  }

  static String _formatText(String text) {
    return text.replaceAll('\$#{1}', '<').replaceAll('\$#{2}', '>').replaceAll('\$#{3}', '\\n').replaceAll('\$#{4}', '\'').replaceAll('\$#{5}', '"').replaceAll('\$#{6}', '&');
  }
}
