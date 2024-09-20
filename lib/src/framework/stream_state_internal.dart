import 'package:maxi_library/maxi_library.dart';

class StreamStateItem<S, R> implements State<S, R> {
  final S item;
  const StreamStateItem({required this.item});
}

class StreamStateResult<S, R> implements State<S, R> {
  final R result;
  const StreamStateResult({required this.result});
}

class StreamStatePartialError<S, R> implements State<S, R> {
  final dynamic partialError;
  const StreamStatePartialError({required this.partialError});
}

class StreamCheckActive<S, R> implements State<S, R> {
  const StreamCheckActive();
}
