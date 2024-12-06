import 'package:maxi_library/maxi_library.dart';

mixin IApplicationManager on StartableFunctionality, IThreadInitializer {
  IOperatorLanguage get languagesOperator;
  List<IReflectorAlbum> get reflectors;
  IThreadManagersFactory get serverThreadsFactory;

  bool get defineLanguageOperatorInOtherThread;
  bool get canHandleFiles;
  bool get isDebug;

  bool get isWeb;
  bool get isLinux;
  bool get isMacOS;
  bool get isWindows;
  bool get isAndroid;
  bool get isIOS;
  bool get isFuchsia;

  bool get isFlutter;

  Future<String> getCurrentDirectory();

  IFileOperator makeFileOperator({required String address, required bool isLocal});

  @override
  Future<void> performInitializationInThread(IThreadManager channel) async {
    ReflectionManager.defineAlbums = reflectors;
    await ApplicationManager.changeInstance(newInstance: this, initialize: true);

    if (defineLanguageOperatorInOtherThread) {
      LanguageManager.changeOperator(languagesOperator);
    }

    DirectoryUtilities.changeFixedCurrentPatch(await getCurrentDirectory());
  }

  @override
  Future<void> initializeFunctionality() async {
    ReflectionManager.defineAlbums = reflectors;
    await LanguageManager.changeOperator(languagesOperator);
    ThreadManager.generalFactory = serverThreadsFactory;

    if (!ThreadManager.instanceDefined) {
      ThreadManager.instance = serverThreadsFactory.createServer(threadInitializer: []);
    }

    DirectoryUtilities.changeFixedCurrentPatch(await getCurrentDirectory());
  }

  void closeAllThreads();
}
