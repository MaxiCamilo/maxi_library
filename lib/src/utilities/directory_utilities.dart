import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:maxi_library/maxi_library.dart';

class _DefineCurrentPathInThreads with IThreadInitializer {
  final String direction;

  const _DefineCurrentPathInThreads({required this.direction});

  @override
  Future<void> performInitializationInThread(IThreadCommunicationMethod channel) async {
    DirectoryUtilities.changeFixedRoute(direction);
  }
}

mixin DirectoryUtilities {
  static const String prefixRouteLocal = '%appdata%';
  static bool useWorkingPath = false;
  static bool useWorkingPathInDebug = true;

  static String? _fixedCurrentPath;
  static bool _initializeDefaultTemporaryPath = false;

  static String get currentPath {
    if (_fixedCurrentPath != null) {
      return _fixedCurrentPath!;
    }

    if (useWorkingPath || (useWorkingPathInDebug && Platform.environment['PUB_ENVIRONMENT'] == 'vscode.dart-code')) {
      _fixedCurrentPath = Directory.current.path;
    } else {
      _fixedCurrentPath = extractFileLocation(fileDirection: Platform.resolvedExecutable, checkPrefix: false);
    }

    ThreadManager.addThreadInitializer(initializer: _DefineCurrentPathInThreads(direction: _fixedCurrentPath!));

    return _fixedCurrentPath!;
  }

  static String interpretPrefix(String route) => route.replaceAll(prefixRouteLocal, currentPath).replaceAll('\\', '/');

  static String serializePrefix(String route) => route.replaceAll(currentPath, prefixRouteLocal).replaceAll('\\', '/');

  static void useDebugPath() {
    _fixedCurrentPath = Directory.current.path;
  }

  static void changeFixedRoute(String newRoute) {
    _fixedCurrentPath = newRoute;
  }

  static Future<String> createFolder(String directoryDirection) async {
    directoryDirection = interpretPrefix(directoryDirection);
    if (await Directory(directoryDirection).exists()) {
      return directoryDirection;
    }

    final partido = directoryDirection.replaceAll('\\', '/').split('/');

    checkProgrammingFailure(thatChecks: tr('The route %1 is not root', [directoryDirection]), result: () => partido.length > 1);

    if (partido.last == '') {
      partido.removeLast();
    }

    final buffer = StringBuffer(partido[0]);

    for (int i = 1; i < partido.length; i++) {
      final parte = partido[i];

      checkProgrammingFailure(thatChecks: tr('Part %1 of %2 is not empty', [parte, directoryDirection]), result: () => parte.isNotEmpty);
      buffer.write('/$parte');
      final total = buffer.toString();
      final carpeta = Directory(total);
      if (!await carpeta.exists()) {
        await volatileAsync(detail: tr('Create folder located at %1', [total]), function: () => carpeta.create());
      }
    }

    return buffer.toString();
  }

  static Future<void> writeFile({
    required String fileDirection,
    required Uint8List content,
    Encoding? encoder,
    FileMode mode = FileMode.write,
  }) async {
    fileDirection = interpretPrefix(fileDirection);
    final file = File(fileDirection);
    if (!await file.exists()) {
      await volatileAsync(detail: tr('Creating text file located at %1', [fileDirection]), function: () => file.create());
    }

    await volatileAsync(detail: tr('Writing text file located at %1', [fileDirection]), function: () => file.writeAsBytes(content, flush: true, mode: mode));
  }

  static Future<void> writeTextFile({
    required String fileDirection,
    required String content,
    Encoding? encoder,
    FileMode mode = FileMode.write,
  }) async {
    fileDirection = interpretPrefix(fileDirection);
    final file = File(fileDirection);
    if (!await file.exists()) {
      if (!await file.exists()) {
        await volatileAsync(detail: tr('Creating text file located at %1', [fileDirection]), function: () => file.create());
      }
    }

    await volatileAsync(detail: tr('Writing text file located at %1', [fileDirection]), function: () => file.writeAsString(content, encoding: encoder ?? utf8, flush: true, mode: mode));
  }

  static Future<String> createFile(String route) async {
    route = interpretPrefix(route);

    if (await File(route).exists()) {
      return route;
    }

    final partido = route.replaceAll('\\', '/').split('/');
    final file = partido.removeLast();

    if (partido.isEmpty) {
      return route;
    }

    final carpeta = await createFolder(partido.join('/'));

    final generado = '$carpeta/$file';
    final instancia = File(generado);
    if (!await instancia.exists()) {
      await volatileAsync(detail: tr('Creating file located at %1', [route]), function: () => instancia.create());
    }

    return generado;
  }

  static Future<void> writeTextFileAsBase64({
    required String fileDirection,
    required String content,
    FileMode mode = FileMode.writeOnly,
  }) async {
    fileDirection = interpretPrefix(fileDirection);
    await createFile(fileDirection);

    await File(fileDirection).writeAsBytes(base64.decode(content), flush: true, mode: mode);
  }

  static Future<void> writeTextFileSecured({
    required String fileDirection,
    required String content,
    FileMode mode = FileMode.writeOnly,
    Encoding? encoder,
  }) async {
    fileDirection = interpretPrefix(fileDirection);
    await createFile(fileDirection);

    await volatileAsync(detail: tr('Writing file located at %1', [fileDirection]), function: () => File(fileDirection).writeAsString(content, flush: true, mode: mode, encoding: encoder ?? utf8));
  }

  static Future<void> writeFileSecured({
    required String fileDirection,
    required Uint8List content,
    FileMode mode = FileMode.writeOnly,
  }) async {
    fileDirection = interpretPrefix(fileDirection);
    await createFile(fileDirection);

    await volatileAsync(detail: tr('Writing file located at %1', [fileDirection]), function: () => File(fileDirection).writeAsBytes(content, flush: true, mode: mode));
  }

  static Future<String> readTextualFile({required String fileDirection, Encoding? encoder, int? maxSize}) async {
    fileDirection = interpretPrefix(fileDirection);
    final file = File(fileDirection);

    if (!await file.exists()) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: tr('The file located at %1 cannot be read because it does not exist', [fileDirection]),
      );
    }

    if (maxSize != null && await file.length() > maxSize) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: tr(
          'The file located at %1 cannot be read because its size exceeds the allowed limit (%2 kb > %3 kb) ',
          [fileDirection, (await file.length() ~/ 1024), (maxSize ~/ 1024)],
        ),
      );
    }

    return await volatileAsync(detail: tr('Reading file located at %1', [fileDirection]), function: () => file.readAsString(encoding: encoder ?? utf8));
  }

  static Future<Uint8List> readFile({required String fileDirection, int? maxSize}) async {
    fileDirection = interpretPrefix(fileDirection);
    final file = File(fileDirection);

    if (!await file.exists()) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: tr('The file located at %1 cannot be read because it does not exist', [fileDirection]),
      );
    }

    if (maxSize != null && await file.length() > maxSize) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: tr(
          'The file located at %1 cannot be read because its size exceeds the allowed limit (%2 kb > %3 kb) ',
          [fileDirection, (await file.length() ~/ 1024), (maxSize ~/ 1024)],
        ),
      );
    }

    return await volatileAsync(detail: tr('Reading file located at %1', [fileDirection]), function: () => file.readAsBytes());
  }

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

  static Future<void> deleteFile(String direction) async {
    direction = interpretPrefix(direction);
    final file = File(direction);

    if (!await file.exists()) {
      return;
    }

    await volatileAsync(detail: tr('Deleting file located at %1', [direction]), function: () => file.delete());
  }

  static Future<void> deleteDirectory(String direction) async {
    direction = interpretPrefix(direction);
    final directory = Directory(direction);

    if (!await directory.exists()) {
      return;
    }
    await volatileAsync(
      detail: tr('Deleting folder located at %1', [direction]),
      function: () => directory.delete(recursive: true),
    );
  }

  static Future<String> copyFile({required String fileDirection, required String destinationFolder}) async {
    fileDirection = interpretPrefix(fileDirection);
    destinationFolder = interpretPrefix(destinationFolder);

    final file = File(fileDirection);

    if (!await file.exists()) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: tr('The file located at %1 could not be copied because it does not exist', [fileDirection]),
      );
    }

    if (!await Directory(destinationFolder).exists()) {
      await createFolder(destinationFolder);
    }

    final newRoute = '$destinationFolder/${extractFileName(route: fileDirection, includeExtension: true)}';

    await volatileAsync(detail: tr('Copying file located at %1 to folder %2', [fileDirection, destinationFolder]), function: () => file.copy(newRoute));
    return newRoute;
  }

  static Future<T> createTemporaryFolder<T>({
    required Future<T> Function(String) funcion,
    String? temporalDirection,
  }) async {
    String localizacionBase = temporalDirection ?? '$currentPath/temporal';
    localizacionBase = interpretPrefix(localizacionBase);

    final numero = Random().nextInt(9999999999);
    final direction = '$localizacionBase/$numero';

    if (temporalDirection == null && !_initializeDefaultTemporaryPath) {
      if (await Directory(localizacionBase).exists()) {
        await Directory(localizacionBase).delete(recursive: true);
      }
      await createFolder(localizacionBase);
      _initializeDefaultTemporaryPath = true;
    }

    final carpeta = Directory(direction);
    checkProgrammingFailure(thatChecks: tr('Temporary folder not found'), result: () => !carpeta.existsSync());

    await volatileAsync(detail: tr('Something went wrong while creating directory %1', [direction]), function: () => carpeta.create());

    late final T dio;
    try {
      dio = await funcion(direction);
      await carpeta.delete(recursive: true);
    } catch (_) {
      await containErrorAsync(function: () => carpeta.delete(recursive: true));
      rethrow;
    }

    return dio;
  }

  static Future<int> getFileSize({required String fileDirection}) async {
    fileDirection = interpretPrefix(fileDirection);
    final file = File(fileDirection);

    if (!await file.exists()) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: tr('The file located at %1 not exist', [fileDirection]),
      );
    }

    return volatileAsync(detail:  tr('Getting file size located at %1', [fileDirection]), function: () => file.length());
  }

  static Future<Uint8List> readFilePartially({required String fileDirection, required int from, required int amount, bool checkSize = true}) async {
    fileDirection = interpretPrefix(fileDirection);

    final file = File(fileDirection);

    if (!await file.exists()) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: tr('The file located at %1 not exist', [fileDirection]),
      );
    }

    final lector = await volatileAsync(detail: tr('Opening file located in %1', [fileDirection]), function: () => file.open(mode: FileMode.read));

    try {
      await lector.setPosition(from);
      if (checkSize) {
        final tamanio = await getFileSize(fileDirection: fileDirection);
        if (tamanio <= from || tamanio <= (from + amount)) {
          amount = tamanio - from;
        }
        if (amount == 0) {
          return Uint8List.fromList([]);
        }
      }

      return await volatileAsync(
        detail:  tr('Reading file %1, from part %2, trying to read %3 bytes', [fileDirection, from, amount]),
        function: () => lector.read(amount),
      );
    } finally {
      containErrorAsync(function: () => lector.close());
    }
  }
}
