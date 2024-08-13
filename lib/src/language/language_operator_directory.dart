import 'dart:collection';
import 'dart:io';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/language/directorys/json/operator_languaje_file_reader_json.dart';
import 'package:maxi_library/src/language/interfaces/ibundle_translated_text.dart';
import 'package:maxi_library/src/language/interfaces/ioperator_language_file_reader.dart';
import 'package:maxi_library/src/language/template_language_operator.dart';
import 'package:maxi_library/src/utilities/directory_utilities.dart';

class LanguageOperatorDirectory extends TemplateLanguageOperator {
  final String translatedFileAddress;
  final IOperatorLanguajeFileReader fileReader;

  final _packagesAvailable = <IBundleTranslatedText>[];

  LanguageOperatorDirectory({
    required super.selectedPrefix,
    this.fileReader = const OperatorLanguajeFileReaderJson(),
    this.translatedFileAddress = '${DirectoryUtilities.prefixRouteLocal}/lang',
  });

  @override
  Future<void> initializeImplementation() async {
    final realAddress = DirectoryUtilities.interpretPrefix(translatedFileAddress);
    await DirectoryUtilities.createFolder(realAddress);
    final directory = Directory(realAddress);

    _packagesAvailable.clear();

    await for (final fileOfDirectory in directory.list()) {
      if (fileOfDirectory is! File) {
        continue;
      }

      if (!await fileReader.isFileCompatible(fileOfDirectory.path)) {
        continue;
      }

      _packagesAvailable.add(await fileReader.generateBundleTranslated(fileOfDirectory.path));
    }
  }

  @override
  Future<SplayTreeMap<String, String>> obtainTranslationScheme(String prefix) {
    final bundle = _packagesAvailable.selectItem((x) => x.prefixLanguage == prefix);
    if (bundle == null) {
      throw NegativeResult(identifier: NegativeResultCodes.nonExistent, message: trc('The language file with prefix %1 was not found', [prefix]));
    }

    return bundle.readTranslatedText();
  }
}
