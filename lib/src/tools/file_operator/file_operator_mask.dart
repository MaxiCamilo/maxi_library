import 'dart:convert';

import 'dart:typed_data';

import 'package:maxi_library/maxi_library.dart';

class FileOperatorMask with IFileOperator, StartableFunctionality {
  @override
  final bool isLocal;

  final String rawRoute;

  late IFileOperator _masked;

  @override
  String get route => isInitialized ? _masked.route : rawRoute;

  FileOperatorMask({required this.isLocal, required this.rawRoute});

  @override
  Future<void> initializeFunctionality() async {
    final masked = ApplicationManager.instance.makeFileOperator(address: rawRoute, isLocal: isLocal);
    if (masked is StartableFunctionality) {
      await (masked as StartableFunctionality).initialize();
    }

    _masked = masked;
  }

  @override
  Future<String> copy({required String destinationFolder, required bool destinationIsLocal}) async {
    await initialize();
    return await _masked.copy(destinationFolder: destinationFolder, destinationIsLocal: destinationIsLocal);
  }

  @override
  Future<void> createAsFile({required bool secured}) async {
    await initialize();
    await _masked.createAsFile(secured: secured);
  }

  @override
  Future<void> createAsFolder({required bool secured}) async {
    await initialize();
    await _masked.createAsFolder(secured: secured);
  }

  @override
  Future<void> deleteDirectory() async {
    await initialize();
    await _masked.deleteDirectory();
  }

  @override
  Future<void> deleteFile() async {
    await initialize();
    await _masked.deleteFile();
  }

  @override
  Future<bool> existsDirectory() async {
    await initialize();
    return await _masked.existsDirectory();
  }

  @override
  Future<bool> existsFile() async {
    await initialize();
    return await _masked.existsFile();
  }

  @override
  Future<int> getFileSize() async {
    await initialize();
    return await _masked.getFileSize();
  }

  @override
  Future<Uint8List> read({int? maxSize}) async {
    await initialize();
    return await _masked.read(maxSize: maxSize);
  }

  @override
  Future<Uint8List> readFilePartially({required int from, required int amount, bool checkSize = true}) async {
    await initialize();
    return await _masked.readFilePartially(from: from, amount: amount, checkSize: checkSize);
  }

  @override
  Future<String> readTextual({Encoding? encoder, int? maxSize}) async {
    await initialize();
    return await _masked.readTextual(encoder: encoder, maxSize: maxSize);
  }

  @override
  Future<void> write({required Uint8List content, bool secured = false}) async {
    await initialize();
    await _masked.write(content: content, secured: secured);
  }

  @override
  Future<void> writeText({required String content, Encoding? encoder, bool secured = false}) async {
    await initialize();
    await _masked.writeText(content: content, encoder: encoder, secured: secured);
  }

  @override
  IFileOperator getContainingFolder() {
    final routeSplit = (isLocal ? '${DirectoryUtilities.currentPath}/$rawRoute' : rawRoute.replaceAll('\\', '/')).split('/');
    if (routeSplit.length < 2) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: tr('Cannot download more from the folder'),
      );
    }

    routeSplit.removeLast();
    return FileOperatorMask(isLocal: false, rawRoute: routeSplit.join('/'));
  }

  @override
  Future<void> add({required Uint8List content, bool secured = false}) async {
    await initialize();
    await _masked.add(content: content, secured: secured);
  }

  @override
  Future<void> addText({required String content, Encoding? encoder, bool secured = false}) async {
    await initialize();
    await _masked.addText(content: content, secured: secured, encoder: encoder);
  }
}
