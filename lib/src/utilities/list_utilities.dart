import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

mixin ListUtilities {
  static Future<List<T>> getFromFunctionWithRange<T>({
    int from = 0,
    int amount = 100,
    required FutureOr<List<T>> Function(int from, int amount) getter,
    int Function(T item)? idGetter,
    bool ascendant = true,
    bool orderHere = false,
    
  }) =>
      streamFromFunctionWithRange<T>(getter: getter, amount: amount, ascendant: ascendant, from: from, idGetter: idGetter, orderHere: orderHere).expand((x) => x).toList();

  static Stream<List<T>> streamFromFunctionWithRange<T>({
    int from = 0,
    int amount = 100,
    required FutureOr<List<T>> Function(int from, int amount) getter,
    int Function(T item)? idGetter,
    bool ascendant = true,
    bool orderHere = false,
  }) async* {
    idGetter ??= (x) => ReflectionManager.getReflectionEntity(T).getPrimaryKey(instance: x);

    int va = from;
    while (true) {
      if (ascendant) {
        List<T> result = await getter(va, amount);
        if (result.isEmpty) {
          break;
        }
        if (orderHere) {
          result = result.orderByFunction(idGetter);
        }

        yield result;
        va = idGetter(result.last) + 1;
      } else {
        List<T> result = await getter(va, amount);
        if (result.isEmpty) {
          break;
        }
        if (orderHere) {
          result = result.orderByFunction(idGetter).reversed.toList();
        }

        yield result;
        va = idGetter(result.last) - 1;
        if (va <= 0) {
          break;
        }
      }
    }
  }
}
