import 'dart:async';
import 'dart:collection';

import 'package:maxi_library/maxi_library.dart';

class EntityList<T> with IEntityWriter<T>, IEntityReader<T> {
  final int splits;

  late final List<IFieldReflection> _uniqueProperties;

  SplayTreeMap<int, T> _mapList = SplayTreeMap<int, T>();

  final _notifyListChanged = StreamController.broadcast();
  final _notifyAssignedItems = StreamController<List<int>>.broadcast();
  final _notifyDeletedItems = StreamController<List<int>>.broadcast();
  final _notifyTotalEliminations = StreamController<void>.broadcast();

  final _blocker = FutureBlocker();

  late final ITypeEntityReflection reflector;

  SplayTreeMap<int, T> get mapList => SplayTreeMap<int, T>.of(_mapList);

  List<T> get list => _mapList.values.toList();

  int _lastPrimaryKey = 0;

  @override
  Stream<void> get notifyListChanged => _notifyListChanged.stream;

  @override
  Stream<List<int>> get notifyAssignedItems => _notifyAssignedItems.stream;

  @override
  Stream<List<int>> get notifyDeletedItems => _notifyDeletedItems.stream;

  @override
  Stream<void> get notifyTotalElimination => _notifyTotalEliminations.stream;

  EntityList({this.splits = 500, List<T>? initList}) {
    reflector = ReflectionManager.getReflectionEntity(T);

    _uniqueProperties = reflector.fields.where((x) => x.annotations.selectByType<UniqueProperty>() != null).toList(growable: false);

    checkProgrammingFailure(thatChecks: Oration(message: 'Entity %1 has primary key', textParts: [T]), result: () => reflector.hasPrimaryKey);

    if (initList != null) {
      for (final item in initList) {
        final key = reflector.getPrimaryKey(instance: item);
        _mapList[key] = item;
      }
    }

    _updateLastPrimaryKey();
  }

  void _updateLastPrimaryKey() {
    if (_mapList.isEmpty) {
      _lastPrimaryKey = 0;
    } else {
      _lastPrimaryKey = _mapList.keys.last;
    }
  }

  void changeList(List<T> list) {
    final newList = SplayTreeMap<int, T>.fromIterable(list.map((x) => MapEntry<int, T>(reflector.getPrimaryKey(instance: x), x)));
    _mapList = newList;
    _updateLastPrimaryKey();
    _notifyListChanged.add(null);
  }

  @override
  Stream<Map<int, bool>> checkWhichExists({required List<int> ids, int? limit, List<IConditionQuery> conditions = const []}) {
    return _blocker.passStream(function: () async => _checkWhichExists(ids: ids, limit: limit, conditions: conditions));
  }

  Stream<Map<int, bool>> _checkWhichExists({required List<int> ids, int? limit, List<IConditionQuery> conditions = const []}) async* {
    for (final part in ids.splitIntoParts(splits)) {
      final result = part.map((x) => MapEntry(x, _mapList.containsKey(x))).toMap();

      for (final part in result.entries.splitIntoParts(limit ?? splits)) {
        yield part.toMap();
      }
    }
  }

  @override
  Stream<List<T>> select({
    int? minimun,
    int? maximum,
    int? limit,
    List<int> certainIds = const [],
    List<IConditionQuery> conditions = const [],
    bool reverse = false,
  }) {
    return _blocker.passStream(
        function: () async => _select(
              certainIds: certainIds,
              conditions: conditions,
              limit: limit,
              maximum: maximum,
              minimun: minimun,
            ));
  }

  Stream<List<T>> _select({
    int? minimun,
    int? maximum,
    int? limit,
    List<int> certainIds = const [],
    List<IConditionQuery> conditions = const [],
    bool reverse = false,
  }) async* {
    limit ??= splits;

    final results = <T>[];

    late final Iterable<MapEntry<int, T>> entityList;

    if (reverse) {
      entityList = _mapList.entries.toList().reversed;
    } else {
      entityList = _mapList.entries;
    }

    for (final candidate in entityList) {
      if (_isSelectable(
        candidate: candidate,
        certainIds: certainIds,
        conditions: conditions,
        maximum: maximum,
        minimun: minimun,
      )) {
        results.add(candidate.value);
        if (results.length >= limit) {
          yield results.toList();
          results.clear();
        }
      }
    }

    if (results.isNotEmpty) {
      yield results;
    }
  }

  bool _isSelectable({
    required MapEntry<int, T> candidate,
    int? minimun,
    int? maximum,
    List<int> certainIds = const [],
    List<IConditionQuery> conditions = const [],
  }) {
    final id = candidate.key;
    final item = candidate.value;

    if (minimun != null && id < minimun) {
      return false;
    }

    if (maximum != null && id > maximum) {
      return false;
    }

    if (certainIds.isNotEmpty && !certainIds.contains(id)) {
      return false;
    }

    for (final condition in conditions) {
      if (!conditionIsAccepted(condition: condition, item: item)) {
        return false;
      }
    }

    return true;
  }

  bool conditionIsAccepted({required IConditionQuery condition, required T item}) {
    if (condition is CompareValue) {
      final propertyValue = reflector.getProperty(name: condition.originField, instance: item);

      return switch (condition.typeComparation) {
        ConditionCompareType.equal => propertyValue == condition.value,
        ConditionCompareType.notEqual => propertyValue != condition.value,
        ConditionCompareType.greater => propertyValue > condition.value,
        ConditionCompareType.less => propertyValue < condition.value,
        ConditionCompareType.greaterEqual => propertyValue >= condition.value,
        ConditionCompareType.lessEqual => propertyValue <= condition.value,
      };
    } else if (condition is CompareFields) {
      final firstValue = reflector.getProperty(name: condition.originField, instance: item);
      final secondValue = reflector.getProperty(name: condition.compareField, instance: item);

      return switch (condition.typeComparation) {
        ConditionCompareType.equal => firstValue == secondValue,
        ConditionCompareType.notEqual => firstValue != secondValue,
        ConditionCompareType.greater => firstValue > secondValue,
        ConditionCompareType.less => firstValue < secondValue,
        ConditionCompareType.greaterEqual => firstValue >= secondValue,
        ConditionCompareType.lessEqual => firstValue <= secondValue,
      };
    } else if (condition is CompareIncludesValues) {
      final propertyValue = reflector.getProperty(name: condition.fieldName, instance: item);

      if (condition.isInclusive) {
        return condition.options.any((x) => x == propertyValue);
      } else {
        return !condition.options.any((x) => x == propertyValue);
      }
    } else if (condition is CompareSimilarText) {
      final value = reflector.getProperty(name: condition.fieldName, instance: item).toString();

      return value.contains(condition.similarText);
    } else if (condition is CompareMultipleComparisons) {
      final result = condition.conditions.map((x) => conditionIsAccepted(condition: x, item: item)).toList();

      return switch (condition.typeComparation) {
        CompareMultipleComparisonsLogic.and => result.every((x) => x),
        CompareMultipleComparisonsLogic.or => result.any((x) => x),
      };
    } else {
      throw '[EntityList] Condition "${condition.runtimeType}" was not developed';
    }
  }

  @override
  Stream<List<int>> selectIDs({
    int? minimun,
    int? maximum,
    int? limit,
    List<IConditionQuery> conditions = const [],
    bool reverse = false,
  }) {
    return _blocker.passStream(
        function: () async => _selectIDs(
              conditions: conditions,
              limit: limit,
              maximum: maximum,
              minimun: minimun,
              reverse: reverse,
            ));
  }

  Stream<List<int>> _selectIDs({
    int? minimun,
    int? maximum,
    int? limit,
    List<IConditionQuery> conditions = const [],
    bool reverse = false,
  }) async* {
    limit ??= splits;

    final results = <int>[];

    late final Iterable<MapEntry<int, T>> entityList;

    if (reverse) {
      entityList = _mapList.entries.toList().reversed;
    } else {
      entityList = _mapList.entries;
    }

    for (final candidate in entityList) {
      if (_isSelectable(
        candidate: candidate,
        conditions: conditions,
        maximum: maximum,
        minimun: minimun,
      )) {
        results.add(candidate.key);
        if (results.length >= limit) {
          yield results.toList();
          results.clear();
        }
      }
    }

    if (results.isNotEmpty) {
      yield results;
    }
  }

  @override
  Stream<StreamState<Oration, void>> deleteAll() {
    return _blocker.blockStream(function: () async => _deleteAll());
  }

  Stream<StreamState<Oration, void>> _deleteAll() async* {
    _mapList.clear();
    _notifyListChanged.add(null);
    _notifyTotalEliminations.add(null);
    yield streamTextStatus(const Oration(message: 'All items were removed from the list'));
    _updateLastPrimaryKey();
  }

  @override
  Stream<StreamState<Oration, void>> add({required List<T> list}) {
    return _blocker.blockStream(function: () async => _add(list: list));
  }

  Stream<StreamState<Oration, void>> _add({required List<T> list}) async* {
    try {
      final newMap = _defineIDZeros(list: list);
      newMap.values.iterar((x) => _checkUniqueProperties(item: x));

      for (final item in newMap.entries) {
        if (_mapList.containsKey(item.key)) {
          throw NegativeResult(
            identifier: NegativeResultCodes.contextInvalidFunctionality,
            message: Oration(message: 'There is already an item in the list with identifier number %1', textParts: [item.key]),
          );
        }
      }

      _mapList.addAll(newMap);
    } finally {
      _defineIDZeros(list: list);
    }

    _updateLastPrimaryKey();
    _notifyListChanged.add(null);
    _notifyAssignedItems.add(list.map((x) => reflector.getPrimaryKey(instance: x)).toList(growable: false));
    yield streamTextStatus(Oration(message: '%1 items have been added to the list', textParts: [list.length]));
  }

  int _getNewId() {
    final id = _lastPrimaryKey + 1;
    _lastPrimaryKey = id;
    return id;
  }

  @override
  Stream<StreamState<Oration, void>> assign({required List<T> list}) {
    return _blocker.blockStream(function: () async => _assign(list: list));
  }

  Stream<StreamState<Oration, void>> _assign({required List<T> list}) async* {
    try {
      final newMap = _defineIDZeros(list: list);
      newMap.values.iterar((x) => _checkUniqueProperties(item: x));

      _mapList.addAll(newMap);
    } finally {
      _updateLastPrimaryKey();
    }
    _notifyListChanged.add(null);
    _notifyAssignedItems.add(list.map((x) => reflector.getPrimaryKey(instance: x)).toList(growable: false));
    yield streamTextStatus(Oration(message: '%1 items have been assigned to the list', textParts: [list.length]));
  }

  @override
  Stream<StreamState<Oration, void>> delete({required List<int> listIDs}) {
    return _blocker.blockStream(function: () async => _delete(listIDs: listIDs));
  }

  Stream<StreamState<Oration, void>> _delete({required List<int> listIDs}) async* {
    listIDs.iterar((x) => _mapList.remove(x));

    _notifyListChanged.add(null);
    _notifyDeletedItems.add(listIDs);
    yield streamTextStatus(Oration(message: '%1 items were deleted in the list', textParts: [listIDs.length]));
    _updateLastPrimaryKey();
  }

  @override
  Stream<StreamState<Oration, void>> modify({required List<T> list}) {
    return _blocker.blockStream(function: () async => _modify(list: list));
  }

  Stream<StreamState<Oration, void>> _modify({required List<T> list}) async* {
    try {
      final newMap = _defineIDZeros(list: list);
      newMap.values.iterar((x) => _checkUniqueProperties(item: x));
      for (final item in newMap.entries) {
        if (!_mapList.containsKey(item.key)) {
          throw NegativeResult(
            identifier: NegativeResultCodes.contextInvalidFunctionality,
            message: Oration(message: 'There is no item in the list with identifier %1', textParts: [item.key]),
          );
        }
      }

      _mapList.addAll(newMap);
    } finally {
      _updateLastPrimaryKey();
    }

    _notifyListChanged.add(null);
    _notifyAssignedItems.add(list.map((x) => reflector.getPrimaryKey(instance: x)).toList(growable: false));
    yield streamTextStatus(Oration(message: '%1 items were modified in the list', textParts: [list.length]));
  }

  @override
  Future<R> reserve<R>(Future<R> Function() function) => _blocker.block(function: function);

  @override
  Stream<R> reserveStream<R>(Future<Stream<R>> Function() function) => _blocker.blockStream(function: function);

  @override
  Future<bool> checkUniqueProperties({required T item}) async {
    for (final property in _uniqueProperties) {
      final value = property.getValue(instance: item);
      for (final candidate in _mapList.entries) {
        final valueCandidate = property.getValue(instance: candidate.value);
        if (value == valueCandidate) {
          return true;
        }
      }
    }

    return false;
  }

  void _checkUniqueProperties({required T item}) {
    for (final property in _uniqueProperties) {
      final value = property.getValue(instance: item);
      for (final candidate in _mapList.entries) {
        final valueCandidate = property.getValue(instance: candidate.value);

        if (reflector.getPrimaryKey(instance: item) == candidate.key) {
          continue;
        }
        if (value == valueCandidate) {
          throw NegativeResult(
            identifier: NegativeResultCodes.contextInvalidFunctionality,
            message: Oration(
              message: 'On the list, item %1 has the same value for property %2. Item %3 cannot be assigned because it is a unique property for each item',
              textParts: [
                candidate.key,
                property.name,
                reflector.getPrimaryKey(instance: item),
              ],
            ),
          );
        }
      }
    }
  }

  Map<int, T> _defineIDZeros({required List<T> list}) {
    final newMaps = <int, T>{};

    int lastId = _getNewId();
    for (final item in list) {
      int actualId = reflector.getPrimaryKey(instance: item);
      if (actualId == 0) {
        actualId = lastId;
        lastId += 1;
        reflector.changePrimaryKey(instance: item, newId: actualId);
      }

      newMaps[actualId] = item;
    }

    return newMaps;
  }
}
