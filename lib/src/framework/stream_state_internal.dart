import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';

class StreamStateItem<S, R> implements StreamState<S, R>, ICustomSerialization {
  final S item;
  const StreamStateItem({required this.item});

  @override
  serialize() {
    if (item is ICustomSerialization) {
      return (item as ICustomSerialization).serialize();
    }

    return item;
  }
}

class StreamStateResult<S, R> implements StreamState<S, R>, ICustomSerialization {
  final R result;
  const StreamStateResult({required this.result});

  @override
  serialize() {
    late final dynamic serializeResult;

    if (result == null) {
      serializeResult = null;
    } else if (result is ICustomSerialization) {
      serializeResult = (result as ICustomSerialization).serialize();
    } else if (result is List) {
      serializeResult = ReflectionManager.serializeList(list: result as List);
    } else if (ReflectionUtilities.isPrimitive(result.runtimeType) != null) {
      serializeResult = result;
    } else {
      serializeResult = ReflectionManager.getReflectionEntity(result.runtimeType).serializeToJson(value: result);
    }

    return json.encode({
      '\$type': 'Result',
      'resultType': serializeResult == null ? 'null' : serializeResult.runtimeType.toString(),
      'value': serializeResult,
    });
  }
}

class StreamStatePartialError<S, R> implements StreamState<S, R>, ICustomSerialization {
  final dynamic partialError;
  const StreamStatePartialError({required this.partialError});

  @override
  serialize() {
    if (partialError is NegativeResult) {
      return (partialError as NegativeResult).serialize();
    }

    if (partialError is ICustomSerialization) {
      return (partialError as ICustomSerialization).serialize();
    }

    return partialError;
  }
}

class StreamCheckActive<S, R> implements StreamState<S, R> {
  const StreamCheckActive();
}
