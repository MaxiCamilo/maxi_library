import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/language/interfaces/ibundle_translated_text.dart';

class BundleTranslatedTextFileJson with IBundleTranslatedText {
  final IReadOnlyFileOperator file;

  @override
  late final String prefixLanguage;

  BundleTranslatedTextFileJson({required this.file}) {
    prefixLanguage = DirectoryUtilities.extractFileName(route: file.route, includeExtension: false).toLowerCase();
  }

  @override
  Future<Map<Oration, String>> readTranslatedText() async {
    final content = await file.readTextual();
    final jsonContent = volatile(detail: Oration(message: 'Processing JSON content from file %1', textParts: [file.route]), function: () => json.decode(content));

    if (jsonContent is Map<String, dynamic>) {
      return Map<Oration, String>.of(jsonContent.map((x, y) => MapEntry(Oration(message: x), y.toString())));
    } else {
      throw NegativeResult(identifier: NegativeResultCodes.wrongType, message: Oration(message: 'The data in file %1 is not formatted as a JSON object', textParts: [file.route]));
    }
  }
}
