import 'package:maxi_library/maxi_library.dart';

class EntityListFile<T> extends EntityList<T> {
  final IFileOperator file;
  final int maxSize;

  EntityListFile._({super.splits, super.initList, required this.file, required this.maxSize});

  static Future<EntityListFile<T>> loadFile<T>({required IFileOperator file, required int maxSize, int? splits}) async {
    final content = await getContentFile<T>(file: file, maxSize: maxSize);

    return EntityListFile._(file: file, maxSize: maxSize, initList: content, splits: splits ?? 500);
  }

  static Future<List<T>> getContentFile<T>({required IFileOperator file, required int maxSize}) async {
    final reflector = ReflectionManager.getReflectionEntity(T);

    if (!await file.existsFile()) {
      await file.writeText(content: '[]');
      return [];
    }

    final content = await file.readTextual(maxSize: maxSize);
    return reflector.interpretJsonAslist(rawText: content, tryToCorrectNames: true, acceptZeroIdentifier: false);
  }

  @override
  Stream<StreamState<Oration, void>> add({required List<T> list}) async* {
    final original = this.list;
    yield* super.add(list: list);
    await _updateOrDisponse(before: original);
  }

  @override
  Stream<StreamState<Oration, void>> modify({required List<T> list}) async* {
    final original = this.list;
    yield* super.modify(list: list);
    await _updateOrDisponse(before: original);
  }

  @override
  Stream<StreamState<Oration, void>> assign({required List<T> list}) async* {
    final original = this.list;
    yield* super.assign(list: list);
    await _updateOrDisponse(before: original);
  }

  @override
  Stream<StreamState<Oration, void>> deleteAll() async* {
    final original = list;
    yield* super.deleteAll();
    await _updateOrDisponse(before: original);
  }

  @override
  Stream<StreamState<Oration, void>> delete({required List<int> listIDs}) async* {
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
    final jsonContent = ReflectionManager.serializeListToJson(value: list);

    if (jsonContent.length > maxSize) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidValue,
        message: Oration(message: 'JSON Result is too big (It supports up to %1 bytes, but the generated JSON is %2 bytes)',textParts: [maxSize, jsonContent.length]),
      );
    }

    return file.writeText(content: jsonContent);
  }
}
