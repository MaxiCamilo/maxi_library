import 'dart:io';

import 'package:maxi_library/maxi_library.dart';

class EntityListFile<T> extends EntityList<T> {
  final String fileAddress;
  final int maxSize;

  EntityListFile._({super.splits, super.initList, required this.fileAddress, required this.maxSize});

  static Future<EntityListFile<T>> loadFile<T>({required String fileAddress, required int maxSize, int? splits}) async {
    final content = await getContentFile<T>(fileAddress: fileAddress, maxSize: maxSize);

    return EntityListFile._(fileAddress: fileAddress, maxSize: maxSize, initList: content, splits: splits ?? 500);
  }

  static Future<List<T>> getContentFile<T>({required String fileAddress, required int maxSize}) async {
    final reflector = ReflectionManager.getReflectionEntity(T);

    final directFileAddress = DirectoryUtilities.interpretPrefix(fileAddress);

    final file = File(directFileAddress);
    if (!await file.exists()) {
      await DirectoryUtilities.writeTextFile(fileDirection: fileAddress, content: '[]');
      return [];
    }

    final content = await DirectoryUtilities.readTextualFile(fileDirection: fileAddress, maxSize: maxSize);
    return reflector.interpretJsonAslist(rawText: content, tryToCorrectNames: true, acceptZeroIdentifier: false);
  }

  @override
  Stream<State<TranslatableText, void>> add({required List<T> list}) async* {
    final original = this.list;
    yield* super.add(list: list);
    await _updateOrDisponse(before: original);
  }

  @override
  Stream<State<TranslatableText, void>> modify({required List<T> list}) async* {
    final original = this.list;
    yield* super.modify(list: list);
    await _updateOrDisponse(before: original);
  }

  @override
  Stream<State<TranslatableText, void>> assign({required List<T> list}) async* {
    final original = this.list;
    yield* super.assign(list: list);
    await _updateOrDisponse(before: original);
  }

  @override
  Stream<State<TranslatableText, void>> deleteAll() async* {
    final original = list;
    yield* super.deleteAll();
    await _updateOrDisponse(before: original);
  }

  @override
  Stream<State<TranslatableText, void>> delete({required List<int> listIDs}) async* {
    final original = list;
    yield* super.delete(listIDs: listIDs);
    await _updateOrDisponse(before: original);
  }

  Future<void> _updateOrDisponse({required List<T> before}) async {
    try {
      await updateFile();
    } catch (_) {
      changeList(before);
      rethrow;
    }
  }

  Future<void> updateFile() {
    final jsonContent = ReflectionManager.serializeListToJson(list: list);

    if (jsonContent.length > maxSize) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidValue,
        message: tr('JSON Result is too big (It supports up to %1 bytes, but the generated JSON is %2 bytes)', [maxSize, jsonContent.length]),
      );
    }

    return DirectoryUtilities.writeTextFile(fileDirection: fileAddress, content: jsonContent);
  }
}
