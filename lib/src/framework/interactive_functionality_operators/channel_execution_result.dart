import 'package:maxi_library/maxi_library.dart';

class ChannelExecutionResult<T> {
  final bool isCorrect;
  final T? result;
  final NegativeResult? error;
  final StackTrace? stackTrace;

  const ChannelExecutionResult({
    required this.isCorrect,
    required this.result,
    required this.error,
    required this.stackTrace,
  });
}
