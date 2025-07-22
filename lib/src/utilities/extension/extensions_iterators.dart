import 'package:maxi_library/maxi_library.dart';

extension IteratorExtension<T> on Iterable<T> {
  Iterable<(int, T)> asPositionalIterable({int start = 0, int? end}) sync* {
    int i = 0;
    end ??= length;

    for (final item in this) {
      if (i > end) {
        break;
      } else if (i >= start) {
        yield (i, item);
      }
    }
  }

  int count(bool Function(T x) funcion) {
    int va = 0;

    for (final item in this) {
      if (funcion(item)) {
        va += 1;
      }
    }

    return va;
  }

  T? selectItem(bool Function(T x) funcion) {
    for (final item in this) {
      if (funcion(item)) {
        return item;
      }
    }

    return null;
  }

  T selectRequiredItem(bool Function(T x) funcion, [Oration? errorText]) {
    for (final item in this) {
      if (funcion(item)) {
        return item;
      }
    }

    throw NegativeResult(identifier: NegativeResultCodes.nonExistent, message: errorText ?? Oration(message: 'The item does not exists'));
  }

  Future<T?> selectItemAsync(Future<bool> Function(T x) funcion) async {
    for (final item in this) {
      if (await funcion(item)) {
        return item;
      }
    }

    return null;
  }

  T maximumOf(num Function(T x) funcion) {
    return reduce((curr, next) => funcion(curr) > funcion(next) ? curr : next);
  }

  R regenerateFromIteration<R>(R inicial, R Function({required R goes, required T item, required int position}) funcion) {
    R goes = inicial;
    int posicion = 0;
    for (final item in this) {
      goes = funcion(goes: goes, item: item, position: posicion);
      posicion += 1;
    }

    return goes;
  }

  bool haveTheSameContent(List<T> other) {
    if (other.length != length) {
      return false;
    }

    int i = 0;
    for (final item in this) {
      if (item != other[i]) {
        return false;
      }
      i += 1;
    }

    return true;
  }

  int maximumOfIdentifier(int Function(T x) funcion) {
    if (isEmpty) {
      return 0;
    }

    int max = 0;

    for (final candidate in this) {
      final result = funcion(candidate);
      if (result > max) {
        max = result;
      }
    }

    return max;
  }

  int minimumOfIdentifier(int Function(T x) funcion) {
    if (isEmpty) {
      return 0;
    }

    int? min;

    for (final candidate in this) {
      final result = funcion(candidate);
      if (min == null) {
        min = result;
      } else if (result < min) {
        min = result;
      }
    }

    return min ?? 0;
  }

  T minimumOf(num Function(T x) funcion) {
    return reduce((curr, next) => funcion(curr) < funcion(next) ? curr : next);
  }

  List<T> orderByFunction(dynamic Function(T) function) {
    final clon = toList();
    clon.sort((a, b) => function(a).compareTo(function(b)));
    return clon;
  }

  List<T> orderByDirectly() => orderByFunction((x) => x);

  T directObtaining(
    bool Function(T x) filtro, {
    Oration? ifNotExists,
  }) {
    for (final item in this) {
      if (filtro(item)) {
        return item;
      }
    }

    throw NegativeResult(
      identifier: NegativeResultCodes.nonExistent,
      message: ifNotExists ?? Oration(message: 'Item not found'),
    );
  }

  R? selectByType<R>() {
    for (final item in this) {
      if (item is R) {
        return item;
      }
    }

    return null;
  }

  int selectPosition(bool Function(T) filtre) {
    int i = 0;
    for (final item in this) {
      if (filtre(item)) {
        return i;
      }
      i += 1;
    }

    return -1;
  }

  void iterarWithPosition(Function(T item, int i) function) {
    int i = 0;
    for (final item in this) {
      function(item, i);
      i += 1;
    }
  }

  void iterar(Function(T) function) {
    for (final item in this) {
      function(item);
    }
  }

  Iterable<List<T>> splitIntoParts(int amount) sync* {
    final temporal = <T>[];
    for (final item in this) {
      temporal.add(item);
      if (temporal.length == amount) {
        yield temporal.toList();
        temporal.clear();
      }
    }

    if (temporal.isNotEmpty) {
      yield temporal;
    }
  }

  List<T> limited({required int amount, bool Function(T x)? where}) {
    final list = <T>[];
    for (final item in this) {
      if (where != null && !where(item)) {
        continue;
      }
      list.add(item);
      if (list.length >= amount) {
        break;
      }
    }

    return list;
  }

  Iterable<R> convert<R>(R Function({required T originalValue, required int position}) function) sync* {
    int i = 0;
    for (final item in this) {
      try {
        yield function(originalValue: item, position: i);
        i += 1;
      } on NegativeResult catch (rn) {
        throw NegativeResultValue(
          message: rn.message,
          identifier: rn.identifier,
          name: (i + 1).toString(),
          formalName: Oration(message: 'Item located at %1', textParts: [i + 1]),
          cause: rn.cause,
        );
      } catch (ex) {
        throw NegativeResult(
          identifier: NegativeResultCodes.nonStandardError,
          message: Oration(message: 'In the list, an item located at position %1 caused an error: %2', textParts: [i + 1, ex.toString()]),
          cause: ex,
        );
      }
    }
  }

  List<T> orderByIdentifier({bool reverse = false}) => ReflectionManager.orderListByIdentifier<T>(list: this, reverse: reverse);

  Map<int, T> mapByIdentifier() => ReflectionManager.mapByIdentifier(list: this).cast<int, T>();

  Iterable<R> mapWithPosition<R>(R Function(T e, int i) toElement) sync* {
    int i = 0;
    for (final item in this) {
      yield toElement(item, i);
      i += 1;
    }
  }

  Iterable<T> extractFromIdentifier(int from, [int? amount]) sync* {
    int va = 0;
    final map = mapByIdentifier();

    for (final item in map.entries) {
      final id = item.key;
      if (id < from) {
        continue;
      }
      yield item.value;
      from = id;
      va += 1;
      if (amount != null && va >= amount) {
        break;
      }
    }
  }

  Stream<T> whereAsync(Future<bool> Function(T) function) async* {
    for (final item in this) {
      if (await function(item)) {
        yield item;
      }
    }
  }
}

extension MapEntryListExtension<T, R> on Iterable<MapEntry<T, R>> {
  Map<T, R> toMap() => Map<T, R>.fromEntries(this);
}

extension ListrExtension<T> on List<T> {
  List<T> extractFrom(int from, [int? amount]) {
    if (isEmpty || from >= length) {
      return [];
    }

    final lista = <T>[];
    amount ??= length - from;
    int va = 0;

    for (int i = from; i < length; i++) {
      if (va >= amount) {
        break;
      }

      lista.add(this[i]);
      va = va + 1;
    }
    return lista;
  }

  List<T> extractUntilValueIsFound(int from, T item) {
    if (isEmpty || from >= length) {
      return [];
    }
    final lista = <T>[];
    int va = 0;

    for (int i = from; i < length; i++) {
      if (this[i] == item) {
        break;
      }

      lista.add(this[i]);
      va = va + 1;
    }
    return lista;
  }

  bool startWith({required Iterable<T> compare, int from = 0}) {
    if (isEmpty) {
      return false;
    }

    if (from >= length) {
      return false;
    }

    for (final item in compare) {
      if (from >= length) {
        return false;
      }

      if (this[from] != item) {
        return false;
      }

      from += 1;
    }

    return true;
  }
}
