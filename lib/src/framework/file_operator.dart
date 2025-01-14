import 'dart:convert';
import 'dart:typed_data';

mixin IFileOperator {
  bool get isLocal;
  String get route;

  Future<bool> existsFile();
  Future<bool> existsDirectory();

  Future<void> createAsFolder({required bool secured});
  Future<void> createAsFile({required bool secured});

  Future<int> getFileSize();

  Future<void> write({required Uint8List content, bool secured = false});
  Future<void> writeText({required String content, Encoding? encoder, bool secured = false});

  Future<void> add({required Uint8List content, bool secured = false});
  Future<void> addText({required String content, Encoding? encoder, bool secured = false});

  Future<String> readTextual({Encoding? encoder, int? maxSize});
  Future<Uint8List> read({int? maxSize});
  Future<Uint8List> readFilePartially({required int from, required int amount, bool checkSize = true});

  Future<void> deleteFile();
  Future<void> deleteDirectory();

  Future<String> copy({required String destinationFolder, required bool destinationIsLocal});

  IFileOperator getContainingFolder();
}
