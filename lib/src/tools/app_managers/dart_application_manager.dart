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
  void changeLocalAddress(String address) {
    _currentDirectory = address;
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

  @override
  void finishApplication() {
    Future.delayed(Duration(milliseconds: 100)).then((value) async {
      exit(0);
    });
  }

  @override
  void resetApplication({List<String> arguments = const []}) {
    Process.run(Platform.resolvedExecutable, arguments);
    finishApplication();
  }

  @override
  void addReflectors(Iterable<GeneratedReflectorAlbum> albums) {
    for (final alb in albums) {
      if (!reflectors.contains(alb)) {
        reflectors.add(alb);
      }
    }

    ReflectionManager.instance.addSeveralsAlbum(albums);
  }
}
