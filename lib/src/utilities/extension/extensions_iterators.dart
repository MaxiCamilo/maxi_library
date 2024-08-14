import 'package:maxi_library/maxi_library.dart';

extension IteratorExtension<T> on Iterable<T> {
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

  T maximumOf(num Function(T x) funcion) {
    return reduce((curr, next) => funcion(curr) > funcion(next) ? curr : next);
  }

  R generateFromIteration<R>(R inicial, R Function({required R goes, required T item, required int position}) funcion) {
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

    final dio = reduce((curr, next) => funcion(curr) > funcion(next) ? curr : next);
    return funcion(dio);
  }

  int minimumOfIdentifier(int Function(T x) funcion) {
    if (isEmpty) {
      return 0;
    }

    final dio = reduce((curr, next) => funcion(curr) < funcion(next) ? curr : next);
    return funcion(dio);
  }

  T minimumOf(num Function(T x) funcion) {
    return reduce((curr, next) => funcion(curr) < funcion(next) ? curr : next);
  }

  List<T> orderByFunction(dynamic Function(T) function) {
    final clon = toList();
    clon.sort((a, b) => function(a).compareTo(function(b)));
    return clon;
  }

  T directObtaining(
    bool Function(T x) filtro, {
    String? ifNotExists,
  }) {
    for (final item in this) {
      if (filtro(item)) {
        return item;
      }
    }

    throw NegativeResult(
      identifier: NegativeResultCodes.nonExistent,
      message: ifNotExists ?? tr('Item not found'),
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

  void startIteration(Function(T x) function) {
    for (final item in this) {
      function(item);
    }
  }

  void startIterationWithPosition(Function(T item, int i) function) {
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
}
