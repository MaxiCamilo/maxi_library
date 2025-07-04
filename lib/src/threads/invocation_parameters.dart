import 'package:maxi_library/maxi_library.dart';

class InvocationParameters with ICustomSerialization {
  final List fixedParameters;
  final Map<String, dynamic> namedParameters;

  const InvocationParameters({this.fixedParameters = const [], this.namedParameters = const {}});

  factory InvocationParameters.clone(InvocationParameters original, {bool avoidConstants = true}) {
    return InvocationParameters(
        fixedParameters: avoidConstants ? original.fixedParameters.toList() : original.fixedParameters, namedParameters: avoidConstants ? Map<String, dynamic>.from(original.namedParameters) : original.namedParameters);
  }

  factory InvocationParameters.addParameters({
    required InvocationParameters original,
    bool addToEnd = true,
    List fixedParameters = const [],
    Map<String, dynamic> namedParameters = const {},
  }) {
    if (addToEnd) {
      return InvocationParameters(
        fixedParameters: [...original.fixedParameters, ...fixedParameters],
        namedParameters: {...original.namedParameters, ...namedParameters},
      );
    } else {
      return InvocationParameters(
        fixedParameters: [...fixedParameters, ...original.fixedParameters],
        namedParameters: {...namedParameters, ...original.namedParameters},
      );
    }
  }

  static const InvocationParameters emptry = InvocationParameters();

  factory InvocationParameters.only(item) => InvocationParameters(fixedParameters: [item]);

  factory InvocationParameters.list(List list) => InvocationParameters(fixedParameters: list);

  factory InvocationParameters.named(Map<String, dynamic> map) => InvocationParameters(namedParameters: map);

  factory InvocationParameters.interpret(Map<String, dynamic> map) {
    return InvocationParameters(
      fixedParameters: map['fixed'] ?? [],
      namedParameters: map['named'] ?? {},
    );
  }

  factory InvocationParameters.interpretFromJson(String text) {
    final jsonObj = ConverterUtilities.interpretToObjectJson(text: text);
    if (jsonObj.getRequiredValueWithSpecificType<String>('\$type') != 'Parameters') {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(message: 'Parameters are invalid or do not have their type label'),
      );
    }

    late final List fixedParameters;
    late final Map<String, dynamic> namedParameters;

    final rawFixed = jsonObj.getRequiredValue('fixed');
    if (rawFixed is String) {
      fixedParameters = ConverterUtilities.interpretToObjectListJson(text: rawFixed);
    } else {
      fixedParameters = volatile(detail: const Oration(message: 'Fixed values are not listed'), function: () => rawFixed as List);
    }

    final rawNamed = jsonObj.getRequiredValue('named');
    if (rawNamed is String) {
      namedParameters = ConverterUtilities.interpretToObjectJson(text: rawNamed);
    } else {
      namedParameters = volatile(detail: const Oration(message: 'Named values are not dictionary'), function: () => rawNamed as Map<String, dynamic>);
    }

    return InvocationParameters(fixedParameters: fixedParameters, namedParameters: namedParameters);
  }

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

  T reverseIndex<T>(int i) => fixed<T>(fixedParameters.length - (i + 1));

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
      message: Oration(message: 'There is no %1 type in the listing of invoction', textParts: [T]),
    );
  }

  T fixed<T>([int location = 0]) {
    checkProgrammingFailure(thatChecks: Oration(message: 'The fixed parameter that is desired is zero or greater (%1 >= 0)', textParts: [location]), result: () => location >= 0);
    checkProgrammingFailure(
        thatChecks: Oration(message: 'The fixed parameter that is desired is less than the amount listed (%1 < %2)', textParts: [location, fixedParameters.length]), result: () => location < fixedParameters.length);

    final item = fixedParameters[location];
    return programmingFailure(
      reasonFailure: Oration(message: 'The item N° %1 is not %2, but it is %3', textParts: [location, T, item.runtimeType]),
      function: () => _convertValue<T>(item),
    );
  }

  T named<T>(String name) {
    checkProgrammingFailure(thatChecks: Oration(message: 'The list is not empty'), result: () => namedParameters.isNotEmpty);

    final item = namedParameters[name];
    checkProgrammingFailure(thatChecks: Oration(message: 'The listing constains an item called "%1"', textParts: [name]), result: () => item != null);
    return programmingFailure(
      reasonFailure: Oration(message: 'The item called  "%1"  is not %2, but it is %3', textParts: [name, T, item.runtimeType]),
      function: () => _convertValue<T>(item),
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
      reasonFailure: Oration(message: 'The item called %1 is not %2, but it is %3', textParts: [name, T, item.runtimeType]),
      function: () => _convertValue<T>(item),
    );
  }

  static T _convertValue<T>(dynamic value) {
    if (value is T) {
      return value;
    }

    final primitiveType = ConverterUtilities.isPrimitive(T);
    if (primitiveType != null) {
      return ConverterUtilities.convertSpecificPrimitive(type: primitiveType, value: value);
    }

    if (ReflectionManager.tryGetReflectionEntity(T) != null) {
      if (value is Map<String, dynamic>) {
        return ReflectionManager.interpret(value: value, tryToCorrectNames: false);
      } else if (value is String) {
        return ReflectionManager.interpretJson(rawText: value, tryToCorrectNames: false);
      }
    }

    throw Oration(
      message: 'It is not possible to convert the value of %1 to %2',
      textParts: [value.runtimeType, T],
    );
  }

  @override
  Map<String, dynamic> serialize() {
    return {
      'fixed': fixedParameters.map((x) => ConverterUtilities.serializeToJson(x)).toList(),
      'named': namedParameters.map((x, y) => MapEntry(x, ConverterUtilities.serializeToJson(y))),
      '\$type': 'Parameters',
    };
  }

  String serializeToJson() => ConverterUtilities.serializeToJson(serialize());
}
