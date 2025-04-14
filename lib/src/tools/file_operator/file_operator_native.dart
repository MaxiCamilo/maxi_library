import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';

import 'package:maxi_library/maxi_library.dart';

class FileOperatorNative with IAbstractFileOperator, IReadOnlyFileOperator, IFileModifierOperator, IFileOperator, StartableFunctionality {
  @override
  final bool isLocal;

  final String rawRoute;

  @override
  late final String route;

  @override
  String get directAddress => checkFirstIfInitialized(() => route);

  FileOperatorNative({required this.isLocal, required this.rawRoute});

  @override
  Future<void> initializeFunctionality() async {
    route = await parseRoute(rawRoute: rawRoute, isLocal: isLocal);
  }

  static Future<String> parseRoute({required String rawRoute, required bool isLocal}) async {
    if (isLocal) {
      final localRoute = await ApplicationManager.instance.getCurrentDirectory();
      return '$localRoute/$rawRoute';
    } else if (rawRoute.contains(DirectoryUtilities.prefixRouteLocal)) {
      final localRoute = await ApplicationManager.instance.getCurrentDirectory();
      return rawRoute.replaceAll(DirectoryUtilities.prefixRouteLocal, localRoute);
    } else {
      return rawRoute;
    }
  }

  @override
  Future<bool> existsDirectory() async {
    await initialize();
    return Directory(route).exists();
  }

  @override
  Future<bool> existsFile() async {
    await initialize();
    return File(route).exists();
  }

  @override
  Future<String> copy({required String destinationFolder, required bool destinationIsLocal}) async {
    await initialize();
    destinationFolder = await parseRoute(rawRoute: destinationFolder, isLocal: destinationIsLocal);

    final file = File(route);

    if (!await file.exists()) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: Oration(message: 'The file located at %1 could not be copied because it does not exist', textParts: [route]),
      );
    }

    if (!await Directory(destinationFolder).exists()) {
      await _createPreviousFolders(destinationFolder);
    }

    final newRoute = '$destinationFolder/${DirectoryUtilities.extractFileName(route: route, includeExtension: true)}';

    await volatileAsync(detail: Oration(message: 'Copying file located at %1 to folder %2', textParts: [route, destinationFolder]), function: () => file.copy(newRoute));
    return newRoute;
  }

  @override
  Future<void> createAsFile({required bool secured}) async {
    await initialize();

    if (await File(route).exists()) {
      return;
    }

    if (secured) {
      final partido = route.replaceAll('\\', '/').split('/');
      final name = partido.removeLast();

      if (await existsDirectory()) {
        throw NegativeResult(
          identifier: NegativeResultCodes.contextInvalidFunctionality,
          message: Oration(message: 'The name "%1" already has a folder at that address', textParts: [name]),
        );
      }

      final folderRoute = partido.join('/');

      if (folderRoute.isNotEmpty) {
        await _createPreviousFolders(folderRoute);
      }
    }

    final instancia = File(route);
    if (!await instancia.exists()) {
      await volatileAsync(detail: Oration(message: 'Creating file located at %1', textParts: [route]), function: () => instancia.create());
    }

    return;
  }

  static Future<void> _createPreviousFolders(String route) async {
    if (await Directory(route).exists()) {
      return;
    }

    final partido = route.replaceAll('\\', '/').split('/');

    checkProgrammingFailure(thatChecks: Oration(message: 'The route %1 is not root', textParts: [partido]), result: () => partido.length > 1);

    if (partido.last == '') {
      partido.removeLast();
    }

    final buffer = StringBuffer(partido[0]);

    for (int i = 1; i < partido.length; i++) {
      final parte = partido[i];

      checkProgrammingFailure(thatChecks: Oration(message: 'Part %1 of %2 is not empty', textParts: [parte, route]), result: () => parte.isNotEmpty);
      buffer.write('/$parte');
      final total = buffer.toString();
      final carpeta = Directory(total);
      if (!await carpeta.exists()) {
        await volatileAsync(detail: Oration(message: 'Create folder located at %1', textParts: [total]), function: () => carpeta.create());
      }
    }

    return;
  }

  @override
  Future<void> createAsFolder({required bool secured}) async {
    await initialize();
    if (await Directory(route).exists()) {
      return;
    }

    if (secured) {
      final partido = route.replaceAll('\\', '/').split('/');
      final name = partido.removeLast();

      if (await existsDirectory()) {
        throw NegativeResult(
          identifier: NegativeResultCodes.contextInvalidFunctionality,
          message: Oration(message: 'The name "%1" already has a file at that address', textParts: [name]),
        );
      }

      final folderRoute = partido.join('/');

      if (folderRoute.isNotEmpty) {
        await _createPreviousFolders(folderRoute);
      }
    }

    final folder = Directory(route);
    if (!await folder.exists()) {
      await volatileAsync(detail: Oration(message: 'Creating file located at %1', textParts: [route]), function: () => folder.create());
    }
  }

  @override
  Future<void> deleteDirectory() async {
    await initialize();

    final folder = Directory(route);
    if (await folder.exists()) {
      await folder.delete(recursive: true);
    }
  }

  @override
  Future<void> deleteFile() async {
    await initialize();

    final file = File(route);
    if (await file.exists()) {
      await file.delete(recursive: true);
    }
  }

  @override
  Future<Uint8List> read({int? maxSize}) async {
    await initialize();

    final file = File(route);

    if (!await file.exists()) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: Oration(message: 'The file located at %1 cannot be read because it does not exist', textParts: [route]),
      );
    }

    if (maxSize != null && await file.length() > maxSize) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: Oration(
          message: 'The file located at %1 cannot be read because its size exceeds the allowed limit (%2 kb > %3 kb) ',
          textParts: [route, (await file.length() ~/ 1024), (maxSize ~/ 1024)],
        ),
      );
    }

    return await volatileAsync(detail: Oration(message: 'Reading file located at %1', textParts: [route]), function: () => file.readAsBytes());
  }

  @override
  Future<String> readTextual({Encoding? encoder, int? maxSize}) async {
    await initialize();

    final file = File(route);

    if (!await file.exists()) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: Oration(message: 'The file located at %1 cannot be read because it does not exist', textParts: [route]),
      );
    }

    if (maxSize != null && await file.length() > maxSize) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: Oration(
          message: 'The file located at %1 cannot be read because its size exceeds the allowed limit (%2 kb > %3 kb) ',
          textParts: [route, (await file.length() ~/ 1024), (maxSize ~/ 1024)],
        ),
      );
    }

    return await volatileAsync(detail: Oration(message: 'Reading file located at %1', textParts: [route]), function: () => file.readAsString(encoding: encoder ?? utf8));
  }

  @override
  Future<void> write({required Uint8List content, bool secured = false}) async {
    await initialize();

    if (secured) {
      await createAsFile(secured: secured);
    }

    await volatileAsync(detail: Oration(message: 'Could not write to file %1', textParts: [route]), function: () => File(route).writeAsBytes(content, flush: true));
  }

  @override
  Future<void> writeText({required String content, Encoding? encoder, bool secured = false, FileMode mode = FileMode.write}) async {
    await initialize();

    if (secured) {
      await createAsFile(secured: secured);
    }

    await volatileAsync(detail: Oration(message: 'Could not write to file %1', textParts: [route]), function: () => File(route).writeAsString(content, flush: true, mode: mode, encoding: encoder ?? utf8));
  }

  @override
  Future<int> getFileSize() async {
    await initialize();
    final file = File(route);

    if (await file.exists()) {
      return await file.length();
    } else {
      return -1;
    }
  }

  @override
  Future<Uint8List> readFilePartially({required int from, required int amount, bool checkSize = true}) async {
    await initialize();

    final file = File(route);

    if (!await file.exists()) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: Oration(message: 'The file located at %1 not exist', textParts: [route]),
      );
    }

    final lector = await volatileAsync(detail: Oration(message: 'Opening file located in %1', textParts: [route]), function: () => file.open(mode: FileMode.read));

    try {
      await lector.setPosition(from);
      if (checkSize) {
        final tamanio = await getFileSize();
        if (tamanio <= from || tamanio <= (from + amount)) {
          amount = tamanio - from;
        }
        if (amount == 0) {
          return Uint8List.fromList([]);
        }
      }

      return await volatileAsync(
        detail: Oration(message: 'Reading file %1, from part %2, trying to read %3 bytes', textParts: [route, from, amount]),
        function: () => lector.read(amount),
      );
    } finally {
      containErrorAsync(function: () => lector.close());
    }
  }

  @override
  IFileOperator getContainingFolder() {
    final routeSplit = rawRoute.replaceAll('\\', '/').split('/');
    if (routeSplit.length < 2) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: Oration(message: 'Cannot download more from the folder'),
      );
    }

    routeSplit.removeLast();
    return FileOperatorNative(isLocal: isLocal, rawRoute: routeSplit.join('/'));
  }

  @override
  Future<void> add({required Uint8List content, bool secured = false}) async {
    await initialize();

    if (secured) {
      await createAsFile(secured: secured);
    }

    await volatileAsync(
        detail: Oration(message: 'Could not write to file %1', textParts: [route]),
        function: () => File(route).writeAsBytes(
              content,
              flush: true,
              mode: FileMode.append,
            ));
  }

  @override
  Future<void> addText({required String content, Encoding? encoder, bool secured = false}) async {
    await initialize();

    if (secured) {
      await createAsFile(secured: secured);
    }

    await volatileAsync(
        detail: Oration(message: 'Could not write to file %1', textParts: [route]),
        function: () => File(route).writeAsString(
              content,
              flush: true,
              mode: FileMode.append,
              encoding: encoder ?? utf8,
            ));
  }

  @override
  Stream<IFileOperator> getFolderContent() async* {
    await initialize();
    final folder = Directory(route);
    if (!await folder.exists()) {
      return;
    }

    yield* folder.list(recursive: true).map((x) => FileOperatorMask(isLocal: false, rawRoute: x.path));
  }

  @override
  Future<DateTime> getCreationDate() async {
    await initialize();

    return FileStat.statSync(route).changed;
  }

  @override
  Future<DateTime> getLastModificationDate() async {
    await initialize();

    return FileStat.statSync(route).modified;
  }
}
