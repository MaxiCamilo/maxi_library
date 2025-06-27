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
  TextableFunctionality<List<int>> add({required List<T> list}) => TextableFunctionalityVoid.express(
        (manager) async {
          final original = this.list;
          final idList = await super.add(list: list).joinExecutor(manager);
          await _updateOrDisponse(before: original);
          return idList;
        },
      );

  @override
  TextableFunctionalityVoid modify({required List<T> list}) => TextableFunctionalityVoid.express(
        (manager) async {
          final original = this.list;
          await super.modify(list: list).joinExecutor(manager);
          await _updateOrDisponse(before: original);
        },
      );

  @override
  TextableFunctionalityVoid assign({required List<T> list}) => TextableFunctionalityVoid.express(
        (manager) async {
          final original = this.list;
          await super.assign(list: list).joinExecutor(manager);
          await _updateOrDisponse(before: original);
        },
      );

  @override
  TextableFunctionalityVoid deleteAll() => TextableFunctionalityVoid.express(
        (manager) async {
          final original = list;
          await super.deleteAll().joinExecutor(manager);
          await _updateOrDisponse(before: original);
        },
      );

  @override
  TextableFunctionalityVoid delete({required List<int> listIDs}) => TextableFunctionalityVoid.express(
        (manager) async {
          final original = list;
          await super.delete(listIDs: listIDs).joinExecutor(manager);
          await _updateOrDisponse(before: original);
        },
      );

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
        message: Oration(message: 'JSON Result is too big (It supports up to %1 bytes, but the generated JSON is %2 bytes)', textParts: [maxSize, jsonContent.length]),
      );
    }

    return file.writeText(content: jsonContent);
  }
}
