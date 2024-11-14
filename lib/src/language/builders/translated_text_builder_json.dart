import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/language/interfaces/itranslated_text_builder.dart';

class TranslatedTextBuilderJson with ITranslatedTextBuilder {
  final String locationToGenerate;

  const TranslatedTextBuilderJson({required this.locationToGenerate});

  @override
  Future<void> generate({required String prefix, required Map<String, String> mapTexts}) async {
    await FileOperatorMask(rawRoute: locationToGenerate, isLocal: false).createAsFolder(secured: true);

    final route = DirectoryUtilities.interpretPrefix('$locationToGenerate/$prefix.json');
    final file = FileOperatorMask(rawRoute: route, isLocal: false);

    await file.deleteFile();
    await file.writeText(content: json.encode(mapTexts));
  }
}
