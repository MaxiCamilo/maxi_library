import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/language/interfaces/ibundle_translated_text.dart';

class BundleTranslatedTextFileJson with IBundleTranslatedText {
  final FileOperatorMask file;

  @override
  late final String prefixLanguage;

  BundleTranslatedTextFileJson({required this.file}) {
    prefixLanguage = DirectoryUtilities.extractFileName(route: file.route, includeExtension: false).toLowerCase();
  }

  @override
  Future<Map<String, String>> readTranslatedText() async {
    final content = await file.readTextual();
    final jsonContent = volatile(detail: tr('Processing JSON content from file %1', [file.route]), function: () => json.decode(content));

    if (jsonContent is Map<String, dynamic>) {
      return Map<String, String>.of(jsonContent.map((x, y) => MapEntry(x, y.toString())));
    } else {
      throw NegativeResult(identifier: NegativeResultCodes.wrongType, message: tr('The data in file %1 is not formatted as a JSON object', [file.route]));
    }
  }
}
