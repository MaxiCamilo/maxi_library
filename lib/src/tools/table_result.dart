import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';

class TableResult extends Iterable<Map<String, dynamic>> {
  final List<String> columnsName;
  late final List<List<dynamic>> values;

  @override
  int get length => values.length;

  @override
  bool get isEmpty => values.isEmpty;

  @override
  bool get isNotEmpty => values.isNotEmpty;

  TableResult({
    required this.columnsName,
    List<List<dynamic>>? values,
  }) {
    this.values = values ?? [];

    int i = 1;
    for (final item in this.values) {
      if (item.length != columnsName.length) {
        throw NegativeResult(
          identifier: NegativeResultCodes.invalidProperty,
          message: tr('Row %1 has %2 values, but it should have %3 values', [i, item.length, columnsName.length]),
        );
      }
      i += 1;
    }
  }

  factory TableResult.emptyTable() => TableResult(columnsName: []);

  bool get nullResult {
    return columnsName.isEmpty || isEmpty;
  }

  dynamic get firstResult {
    if (nullResult) {
      return null;
    }

    return values[0].first;
  }

  @override
  Iterator<Map<String, dynamic>> get iterator => generarIterador().iterator;

  Iterable<Map<String, dynamic>> generarIterador() sync* {
    for (int i = 0; i < length; i++) {
      yield getRowValues(position: i);
    }
  }

  Map<String, dynamic> getRowValues({required int position}) {
    if (position < 0 || position > length) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: tr('The table has %1 rows, but an attempt was made to get the %2 position (starting from zero)', [length, position]),
      );
    }

    final mapValues = <String, dynamic>{};
    final positionValue = values[position];

    for (int i = 0; i < columnsName.length; i++) {
      mapValues.addAll({columnsName[i]: positionValue[i]});
    }

    return mapValues;
  }

  Map<String, List<dynamic>> getAllValues() {
    final Map<String, List<dynamic>> newMap = {};

    for (int i = 0; i < columnsName.length; i++) {
      final name = columnsName[i];
      final newList = [];
      for (int x = 0; x < values.length; x++) {
        final fila = values[x];
        newList.add(fila[i]);
      }
      newMap.addAll({name: newList});
    }
    return newMap;
  }

  int? getColumnPositionByName({required String columnName, bool caseSensitivity = true}) {
    return columnsName.selectPosition((x) => columnName == x || (!caseSensitivity && columnName.toLowerCase() == x.toLowerCase()));
  }

  List<dynamic> getColumnContentByName({required String columnName, bool caseSensitivity = true}) {
    final position = getColumnPositionByName(columnName: columnName, caseSensitivity: caseSensitivity);
    if (position == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: tr('The table does not contain the column %1', [columnName]),
      );
    }

    final newList = [];

    for (int x = 0; x < values.length; x++) {
      final fila = values[x];
      newList.add(fila[position]);
    }

    return newList;
  }

  List<dynamic> getColumnContentByPosition({required int position}) {
    if (position < 0 || position > length) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: tr('The table has %1 columns, but an attempt was made to get the %2 position (starting from zero)', [columnsName.length, position]),
      );
    }

    final newList = [];

    for (int x = 0; x < values.length; x++) {
      final fila = values[x];
      newList.add(fila[position]);
    }

    return newList;
  }

  int addRow({required Map<String, dynamic> content}) {
    final newList = [];

    for (final name in columnsName) {
      if (content.containsKey(name)) {
        newList.add(content[name]);
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.contextInvalidFunctionality,
          message: tr('An attempt was made to add a row, but column %1 is missing', [name]),
        );
      }
    }

    final position = length;
    values.add(newList);
    return position;
  }

  int addRowWithList({required List list}) {
    if (list.length != columnsName.length) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidValue,
        message: tr('Cannot add an invalid list, the list contains %1 values, but the table have %2 columns', [list.length, columnsName.length]),
      );
    }

    final position = length;
    values.add(list);
    return position;
  }

  dynamic getValueByPosition({required int positionColumn, required int positionValue}) {
    if (positionColumn < 0 || positionColumn > length) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: tr('The table has %1 columns, but an attempt was made to get the %2 position (starting from zero)', [columnsName.length, positionColumn]),
      );
    }

    final name = columnsName[positionColumn];
    final row = getRowValues(position: positionValue);
    return row[name];
  }

  dynamic getValueByName({required String columnName, required int positionValue, bool caseSensitivity = true}) {
    final position = getColumnPositionByName(columnName: columnName, caseSensitivity: caseSensitivity);
    if (position == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: tr('The table does not contain the column %1', [columnName]),
      );
    }

    final row = getRowValues(position: positionValue);
    return row[columnsName[position]];
  }

  void removeRow({required int position}) {
    if (position < 0 || position >= length) {
      return;
    }

    values.removeAt(position);
  }

  void clean() {
    values.clear();
  }

  void changeRow({required int position, required Map<String, dynamic> newValues, bool caseSensitivity = true}) {
    final originalValue = getRowValues(position: position);

    for (final part in originalValue.entries.toList(growable: false)) {
      if (caseSensitivity) {
        if (newValues.containsKey(part.key)) {
          originalValue[part.key] = newValues[part.key];
        }
      } else {
        for (final possiblePart in newValues.entries) {
          if (possiblePart.key.toLowerCase() == part.key.toLowerCase()) {
            originalValue[part.key] = newValues[possiblePart.key];
            break;
          }
        }
      }
    }
  }

  @override
  String toString() => json.encode(generarIterador().toList());
}
