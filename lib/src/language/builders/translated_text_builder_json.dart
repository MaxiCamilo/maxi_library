import 'dart:convert';

import 'package:maxi_library/src/language/interfaces/itranslated_text_builder.dart';
import 'package:maxi_library/src/utilities/directory_utilities.dart';

class TranslatedTextBuilderJson with ITranslatedTextBuilder {
  final String locationToGenerate;

  const TranslatedTextBuilderJson({required this.locationToGenerate});

  @override
  Future<void> generate({required String prefix, required Map<String, String> mapTexts}) async {
    await DirectoryUtilities.createFolder(locationToGenerate);

    final route = DirectoryUtilities.interpretPrefix('$locationToGenerate/$prefix.json');

    await DirectoryUtilities.deleteFile(route);
    await DirectoryUtilities.writeTextFile(fileDirection: route, content: json.encode(mapTexts));
  }
}
