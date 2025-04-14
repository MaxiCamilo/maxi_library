import 'dart:math' show Random;

import 'package:maxi_library/maxi_library.dart';

class TempFolder with StartableFunctionality, FunctionalityWithLifeCycle {
  static bool _tempFolderCreated = false;
  late String _currectAddress;
  late FileOperatorMask _folderInstance;

  String get address => checkFirstIfInitialized(() => _currectAddress);
  FileOperatorMask get folder => checkFirstIfInitialized(() => _folderInstance);

  Future<List<IFileOperator>> getAllContent() async {
    await initialize();
    return await _folderInstance.getFolderContent().whereType<IFileOperator>().toList();
  }

  @override
  Future<void> afterInitializingFunctionality() async {
    if (!await ThreadManager.instance.callFunctionOnTheServer(function: (_) => TempFolder._tempFolderCreated)) {
      final tempFolder = FileOperatorMask(isLocal: true, rawRoute: 'temp');
      if (await tempFolder.existsDirectory()) {
        await tempFolder.deleteDirectory();
      }
      await tempFolder.createAsFolder(secured: true);

      await ThreadManager.instance.callFunctionOnTheServer(function: (_) => TempFolder._tempFolderCreated = true);
      //_tempFolderCreated = true;
    }

    final numero = Random().nextInt(4294967296);
    _folderInstance = FileOperatorMask(isLocal: true, rawRoute: 'temp/$numero');

    await checkProgrammingFailureAsync(thatChecks: Oration(message: 'Temporary folder not found'), result: () async => !await _folderInstance.existsDirectory());

    await _folderInstance.createAsFolder(secured: false);
    _currectAddress = _folderInstance.directAddress;
  }

  @override
  void afterDiscard() {
    containErrorLogAsync(
      detail: Oration(message: 'Delete temp folder %1', textParts: [_folderInstance.directAddress]),
      function: () => _folderInstance.deleteDirectory(),
    );
  }
}
