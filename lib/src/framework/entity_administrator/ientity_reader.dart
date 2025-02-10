import 'package:maxi_library/maxi_library.dart';

mixin IEntityReader<T> {
  Stream<List<T>> select({
    int? minimun,
    int? maximum,
    int? limit,
    List<int> certainIds = const [],
    List<IConditionQuery> conditions = const [],
    bool reverse = false,
  });

  Stream<List<int>> selectIDs({
    int? minimun,
    int? maximum,
    int? limit,
    List<IConditionQuery> conditions = const [],
    bool reverse = false,
  });

  Stream<Map<int, bool>> checkWhichExists({
    required List<int> ids,
    int? limit,
    List<IConditionQuery> conditions = const [],
  });

  Future<List<T>> selectAsList({
    int? minimun,
    int? maximum,
    int? limit,
    List<int> certainIds = const [],
    List<IConditionQuery> conditions = const [],
    bool reverse = false,
    bool growable = true,
  }) async {
    return (await select(minimun: minimun, maximum: maximum, limit: limit, certainIds: certainIds, conditions: conditions, reverse: reverse).toList()).expand((x) => x).toList(growable: growable);
  }

  Future<List<int>> selectIDsAsList({
    int? minimun,
    int? maximum,
    int? limit,
    List<IConditionQuery> conditions = const [],
    bool reverse = false,
    bool growable = true,
  }) async {
    return (await selectIDs().toList()).expand((x) => x).toList(growable: growable);
  }

  Future<Map<int, bool>> checkWhichExistsAsMap({
    required List<int> ids,
    int? limit,
    List<IConditionQuery> conditions = const [],
  }) async {
    final newMap = <int, bool>{};
    await for (final item in checkWhichExists(ids: ids, limit: limit, conditions: conditions)) {
      newMap.addAll(item);
    }

    return newMap;
  }

  Future<bool> exists({required int id}) async {
    final map = await checkWhichExistsAsMap(ids: [id]);
    return map[id]!;
  }

  Future<T?> tryToLocate({required int id}) async {
    final list = await selectAsList(certainIds: [id]);
    if (list.isEmpty) {
      return null;
    } else {
      return list.first;
    }
  }

  Future<T> locate({required int id}) async {
    final item = await tryToLocate(id: id);
    if (item == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: Oration(message: 'The item with identifier number %1 could not be found', textParts: [id]),
      );
    } else {
      return item;
    }
  }
}
