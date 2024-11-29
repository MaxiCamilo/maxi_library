import 'package:maxi_library/maxi_library.dart';

class InvocationParameters {
  final List fixedParameters;
  final Map<String, dynamic> namedParameters;

  const InvocationParameters({this.fixedParameters = const [], this.namedParameters = const {}});

  factory InvocationParameters.clone(InvocationParameters original, {bool avoidConstants = true}) {
    return InvocationParameters(
        fixedParameters: avoidConstants ? original.fixedParameters.toList() : original.fixedParameters, namedParameters: avoidConstants ? Map<String, dynamic>.from(original.namedParameters) : original.namedParameters);
  }

  static const InvocationParameters emptry = InvocationParameters();

  factory InvocationParameters.only(item) => InvocationParameters(fixedParameters: [item]);

  factory InvocationParameters.list(List list) => InvocationParameters(fixedParameters: list);

  factory InvocationParameters.named(Map<String, dynamic> map) => InvocationParameters(namedParameters: map);

  operator []=(String name, dynamic value) => namedParameters[name] = value;

  T firts<T>() => fixed<T>(0);

  T second<T>() => fixed<T>(1);

  T third<T>() => fixed<T>(2);

  T fourth<T>() => fixed<T>(3);

  T fifth<T>() => fixed<T>(4);

  T sixth<T>() => fixed<T>(5);

  T seventh<T>() => fixed<T>(6);

  T octave<T>() => fixed<T>(7);

  T ninth<T>() => fixed<T>(8);

  T last<T>() => fixed<T>(fixedParameters.length - 1);
  T penultimate<T>() => fixed<T>(fixedParameters.length - 2);
  T antepenultimate<T>() => fixed<T>(fixedParameters.length - 3);

  T searchByType<T>() {
    for (final item in fixedParameters) {
      if (item is T) {
        return item;
      }
    }

    for (final item in namedParameters.values) {
      if (item is T) {
        return item;
      }
    }

    throw throw NegativeResult(
      identifier: NegativeResultCodes.implementationFailure,
      message: tr('There is no %1 type in the listing of invoction', [T]),
    );
  }

  T fixed<T>([int location = 0]) {
    checkProgrammingFailure(thatChecks: tr('The fixed parameter that is desired is zero or greater (%1 >= 0)', [location]), result: () => location >= 0);
    checkProgrammingFailure(thatChecks: tr('The fixed parameter that is desired is less than the amount listed (%1 < %2)', [location, fixedParameters.length]), result: () => location < fixedParameters.length);

    final item = fixedParameters[location];
    return programmingFailure(
      reasonFailure: tr('The item N° %1 is not %2, but it is %3', [location, T, item.runtimeType]),
      function: () => item as T,
    );
  }

  T named<T>(String name) {
    checkProgrammingFailure(thatChecks: tr('The list is not empty'), result: () => namedParameters.isNotEmpty);

    final item = namedParameters[name];
    checkProgrammingFailure(thatChecks: tr('The listing constains an item called "%1"', [name]), result: () => item != null);
    return programmingFailure(
      reasonFailure: tr('The item called  "%1"  is not %2, but it is %3', [name, T, item.runtimeType]),
      function: () => item as T,
    );
  }

  T? namedOptional<T>(String name, [T? predetermined]) {
    if (namedParameters.isEmpty) {
      return predetermined;
    }

    final item = namedParameters[name];
    if (item == null) {
      return predetermined;
    }

    return programmingFailure(
      reasonFailure: tr('The item called %1 is not %2, but it is %3', [name, T, item.runtimeType]),
      function: () => item as T,
    );
  }
}
