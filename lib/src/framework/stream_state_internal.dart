import 'package:maxi_library/maxi_library.dart';

class StreamStateItem<S, R> implements State<S, R>, ICustomSerialization {
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

class StreamStateResult<S, R> implements State<S, R>, ICustomSerialization {
  final R result;
  const StreamStateResult({required this.result});

  @override
  serialize() {
    if (result is ICustomSerialization) {
      return (result as ICustomSerialization).serialize();
    }

    return result;
  }
}

class StreamStatePartialError<S, R> implements State<S, R>, ICustomSerialization {
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

class StreamCheckActive<S, R> implements State<S, R> {
  const StreamCheckActive();
}
