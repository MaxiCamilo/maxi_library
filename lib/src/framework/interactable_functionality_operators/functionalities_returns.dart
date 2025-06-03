import 'package:maxi_library/maxi_library.dart';

class FunctionalityItem<I> with ICustomSerialization {
  final I item;
  final int idetifier;

  const FunctionalityItem({required this.item, required this.idetifier});

  static FunctionalityItem<I> interpret<I>(Map<String, dynamic> map) {
    final id = map.getRequiredValueWithSpecificType<int>('id');
    final item = ConverterUtilities.castJson<I>(text: map.getRequiredValueWithSpecificType<String>('item'));

    return FunctionalityItem<I>(idetifier: id, item: item);
  }

  @override
  Map<String, dynamic> serialize() {
    return {
      'id': idetifier,
      '\$type': 'item',
      'item': ConverterUtilities.serializeToJson(item),
    };
  }
}

class FunctionalityResult<R> with ICustomSerialization {
  final R result;
  final int idetifier;

  const FunctionalityResult({required this.result, required this.idetifier});

  static FunctionalityResult<R> interpret<R>(Map<String, dynamic> map) {
    final id = map.getRequiredValueWithSpecificType<int>('id');
    final result = ConverterUtilities.castJson<R>(text: map.getRequiredValueWithSpecificType<String>('result'));

    return FunctionalityResult<R>(idetifier: id, result: result);
  }

  @override
  Map<String, dynamic> serialize() {
    return {
      'id': idetifier,
      '\$type': 'result',
      'result': result == null ? '' : ConverterUtilities.serializeToJson(result),
    };
  }
}

class FunctionalityError with ICustomSerialization {
  final NegativeResult error;
  final StackTrace stackTrace;
  final int idetifier;

  const FunctionalityError({required this.error, required this.stackTrace, required this.idetifier});

  factory FunctionalityError.interpret(Map<String, dynamic> map) {
    final id = map.getRequiredValueWithSpecificType<int>('id');
    final error = NegativeResult.interpretJson(jsonText: map.getRequiredValueWithSpecificType<String>('error'));
    final stackTrace = StackTrace.fromString(map.getRequiredValueWithSpecificType<String>('stackTrace'));

    return FunctionalityError(idetifier: id, error: error, stackTrace: stackTrace);
  }

  @override
  Map<String, dynamic> serialize() {
    return {
      'id': idetifier,
      '\$type': 'failed',
      'error': error.serializeToJson(),
      'stackTrace': stackTrace.toString(),
    };
  }
}
