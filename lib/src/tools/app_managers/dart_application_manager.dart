import 'dart:io';

import 'package:maxi_library/maxi_library.dart';

class DartApplicationManager with StartableFunctionality, IThreadInitializer, IApplicationManager {
  @override
  final bool defineLanguageOperatorInOtherThread;

  @override
  final List<IReflectorAlbum> reflectors;

  @override
  final IOperatorLanguage languagesOperator;

  @override
  final IThreadManagersFactory serverThreadsFactory;

  final bool useWorkingPath;
  final bool useWorkingPathInDebug;

  String? _currentDirectory;

  DartApplicationManager({
    required this.defineLanguageOperatorInOtherThread,
    required this.reflectors,
    IOperatorLanguage? languagesOperator,
    IThreadManagersFactory? serverThreadsFactory,
    this.useWorkingPath = false,
    this.useWorkingPathInDebug = true,
  })  : languagesOperator = languagesOperator ?? LanguageOperatorBasic(),
        serverThreadsFactory = serverThreadsFactory ?? const IsolatedThreadFactory();

  @override
  bool get canHandleFiles => true;

  @override
  Future<String> getCurrentDirectory() async {
    if (_currentDirectory == null) {
      if (useWorkingPathInDebug && isDebug) {
        _currentDirectory = isDebug ? '${Directory.current.path}/debug' : Directory.current.path;
        if (isDebug && !await Directory(_currentDirectory!).exists()) {
          await Directory(_currentDirectory!).create();
        }
      } else if (useWorkingPath) {
        _currentDirectory = Directory.current.path;
      } else {
        _currentDirectory = DirectoryUtilities.extractFileLocation(fileDirection: Platform.resolvedExecutable, checkPrefix: false);
      }
    }
    return _currentDirectory!;
  }

  @override
  bool get isAndroid => Platform.isAndroid;

  @override
  bool get isDebug => Platform.environment['PUB_ENVIRONMENT'] == 'vscode.dart-code';

  @override
  bool get isFuchsia => Platform.isFuchsia;

  @override
  bool get isIOS => Platform.isIOS;

  @override
  bool get isLinux => Platform.isLinux;

  @override
  bool get isMacOS => Platform.isMacOS;

  @override
  bool get isWeb => false;

  @override
  bool get isWindows => Platform.isWindows;

  @override
  bool get isFlutter => false;

  @override
  IFileOperator makeFileOperator({required String address, required bool isLocal}) {
    return FileOperatorNative(isLocal: isLocal, rawRoute: address);
  }

  @override
  void closeAllThreads() {
    if (ThreadManager.instance is IThreadManagerServer) {
       (ThreadManager.instance as IThreadManagerServer).closeAllThread();
    } else {
       ThreadManager.instance.callFunctionOnTheServer(function: (x) => (ThreadManager.instance as IThreadManagerServer).closeAllThread());
    }
  }
}
