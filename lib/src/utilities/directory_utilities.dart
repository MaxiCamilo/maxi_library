import 'package:maxi_library/maxi_library.dart';

class _DefineCurrentPathInThreads with IThreadInitializer {
  final String direction;

  const _DefineCurrentPathInThreads({required this.direction});

  @override
  Future<void> performInitializationInThread(IThreadManager channel) async {
    DirectoryUtilities._fixedCurrentPath = direction;
  }
}

mixin DirectoryUtilities {
  static const String prefixRouteLocal = '%appdata%';

  static String? _fixedCurrentPath;

  static String get currentPath {
    if (_fixedCurrentPath == null) {
      throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: Oration(message: 'Application operator not initialized, need to know local path'));
    }

    return _fixedCurrentPath!;
  }

  static void changeFixedCurrentPatch(String path) {
    _fixedCurrentPath = path.replaceAll('\\', '/');
    ThreadManager.addThreadInitializer(initializer: _DefineCurrentPathInThreads(direction: path));
  }

  static String interpretPrefix(String route) => route.replaceAll(prefixRouteLocal, currentPath).replaceAll('\\', '/');

  static String serializePrefix(String route) => route.replaceAll(currentPath, prefixRouteLocal).replaceAll('\\', '/');

  static String extractFileName({required String route, required bool includeExtension}) {
    route = interpretPrefix(route);
    final partido = route.replaceAll('\\', '/').split('/');
    final nameFile = partido.last;
    final hasPoint = nameFile.contains('.');

    if (includeExtension || !hasPoint) {
      return nameFile;
    }

    final nameParted = nameFile.split('.');
    nameParted.removeLast();

    return nameParted.join();
  }

  static String extractFileExtension(String route) {
    route = interpretPrefix(route);
    final nombre = extractFileName(route: route, includeExtension: true);
    if (!route.contains('.')) {
      return '';
    }

    return nombre.split('.').last;
  }

  static String extractFileLocation({required String fileDirection, bool checkPrefix = true}) {
    if (checkPrefix) {
      fileDirection = interpretPrefix(fileDirection);
    }
    final buffer = StringBuffer();
    final partido = fileDirection.replaceAll('\\', '/').split('/');

    for (int i = 0; i < partido.length - 1; i++) {
      buffer.write(partido[i]);
      if (i < partido.length - 2) {
        buffer.write('/');
      }
    }

    if (buffer.isEmpty) {
      return currentPath;
    }

    return buffer.toString();
  }


}
