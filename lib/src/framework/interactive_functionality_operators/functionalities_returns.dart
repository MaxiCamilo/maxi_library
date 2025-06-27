import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';

class FunctionalityItem<I> with ICustomSerialization {
  final I item;

  const FunctionalityItem({required this.item});

  static FunctionalityItem<I> interpret<I>(Map<String, dynamic> map) {
    final item = ConverterUtilities.castJson<I>(text: map.getRequiredValueWithSpecificType<String>('item'));

    return FunctionalityItem<I>(item: item);
  }

  @override
  Map<String, dynamic> serialize() {
    return {
      '\$type': 'item',
      'item': ConverterUtilities.serializeToJson(item),
    };
  }

  String serializeToJson() => json.encode(serialize());
}

class FunctionalityCancel with ICustomSerialization {
  const FunctionalityCancel();

  static FunctionalityCancel interpret(Map<String, dynamic> map) {
    return FunctionalityCancel();
  }

  @override
  Map<String, dynamic> serialize() {
    return {
      '\$type': 'cancel',
    };
  }

  String serializeToJson() => json.encode(serialize());
}

class FunctionalityResult<R> with ICustomSerialization {
  final R result;

  const FunctionalityResult({required this.result});

  static FunctionalityResult<R> interpret<R>(Map<String, dynamic> map) {
    final result = ConverterUtilities.castJson<R>(text: map.getRequiredValueWithSpecificType<String>('result'));

    return FunctionalityResult<R>(result: result);
  }

  @override
  Map<String, dynamic> serialize() {
    return {
      '\$type': 'result',
      'result': result == null ? '' : ConverterUtilities.serializeToJson(result),
    };
  }

  String serializeToJson() => json.encode(serialize());
}

class FunctionalityError with ICustomSerialization {
  final NegativeResult error;
  final StackTrace stackTrace;

  const FunctionalityError({required this.error, required this.stackTrace});

  factory FunctionalityError.interpret(Map<String, dynamic> map) {
    final error = NegativeResult.interpretJson(jsonText: map.getRequiredValueWithSpecificType<String>('error'));
    final stackTrace = StackTrace.fromString(map.getRequiredValueWithSpecificType<String>('stackTrace'));

    return FunctionalityError(error: error, stackTrace: stackTrace);
  }

  @override
  Map<String, dynamic> serialize() {
    return {
      '\$type': 'failed',
      'error': error.serializeToJson(),
      'stackTrace': stackTrace.toString(),
    };
  }

  String serializeToJson() => json.encode(serialize());
}
