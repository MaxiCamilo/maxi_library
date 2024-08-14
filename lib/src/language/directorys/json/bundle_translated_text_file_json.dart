import 'dart:collection';
import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/language/interfaces/ibundle_translated_text.dart';
import 'package:maxi_library/src/utilities/directory_utilities.dart';

class BundleTranslatedTextFileJson with IBundleTranslatedText {
  final String direction;

  @override
  late final String prefixLanguage;

  BundleTranslatedTextFileJson({required this.direction}) {
    prefixLanguage = DirectoryUtilities.extractFileName(route: direction, includeExtension: false);
  }

  @override
  Future<SplayTreeMap<String, String>> readTranslatedText() async {
    final content = await DirectoryUtilities.readTextualFile(fileDirection: direction);
    final jsonContent = volatile(detail: () => trc('Processing JSON content from file %1', [direction]), function: () => json.decode(content));

    if (jsonContent is Map<String, dynamic>) {
      return SplayTreeMap<String, String>.of(jsonContent.map((x, y) => MapEntry(x, y.toString())));
    } else {
      throw NegativeResult(identifier: NegativeResultCodes.wrongType, message: trc('The data in file %1 is not formatted as a JSON object', [direction]));
    }
  }
}
