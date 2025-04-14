import 'dart:convert';
import 'dart:typed_data';

import 'package:maxi_library/maxi_library.dart';

mixin IFileOperator on IAbstractFileOperator, IReadOnlyFileOperator, IFileModifierOperator {}

mixin IAbstractFileOperator {
  bool get isLocal;
  String get route;
  String get directAddress;

  Future<bool> existsFile();
  Future<bool> existsDirectory();
}

mixin IReadOnlyFileOperator on IAbstractFileOperator {
  Future<int> getFileSize();

  Future<String> readTextual({Encoding? encoder, int? maxSize});
  Future<Uint8List> read({int? maxSize});
  Future<Uint8List> readFilePartially({required int from, required int amount, bool checkSize = true});

  Future<DateTime> getLastModificationDate();
  Future<DateTime> getCreationDate();

  IReadOnlyFileOperator getContainingFolder();
  Stream<IReadOnlyFileOperator> getFolderContent();

  Future<void> itFileMustExist() async {
    if (!await existsFile()) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: Oration(
          message: 'There is no %1 file in the %2 folder',
          textParts: [
            DirectoryUtilities.extractFileName(route: route, includeExtension: true),
            DirectoryUtilities.extractFileLocation(fileDirection: route),
          ],
        ),
      );
    }
  }
}

mixin IFileModifierOperator on IAbstractFileOperator {
  
  Future<void> createAsFolder({required bool secured});
  Future<void> createAsFile({required bool secured});
  Future<void> add({required Uint8List content, bool secured = false});
  Future<void> addText({required String content, Encoding? encoder, bool secured = false});
  Future<void> write({required Uint8List content, bool secured = false});
  Future<void> writeText({required String content, Encoding? encoder, bool secured = false});
  Future<void> deleteFile();
  Future<void> deleteDirectory();
  Future<String> copy({required String destinationFolder, required bool destinationIsLocal});
}
