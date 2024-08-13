import 'package:maxi_library/src/language/directorys/json/bundle_translated_text_file_json.dart';
import 'package:maxi_library/src/language/interfaces/ibundle_translated_text.dart';
import 'package:maxi_library/src/language/interfaces/ioperator_language_file_reader.dart';
import 'package:maxi_library/src/utilities/directory_utilities.dart';

class OperatorLanguajeFileReaderJson with IOperatorLanguajeFileReader {
  const OperatorLanguajeFileReaderJson();

  @override
  Future<bool> isFileCompatible(String fileDirection) async {
    return DirectoryUtilities.extractFileExtension(fileDirection) != 'json';
  }

  @override
  Future<IBundleTranslatedText> generateBundleTranslated(String fileDirection) async {
    return BundleTranslatedTextFileJson(direction: fileDirection);
  }
}
