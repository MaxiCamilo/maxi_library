import 'package:maxi_library/src/threads/interfaces/ithread_message.dart';

class ThreadExecutionFinished with IThreadMessage {
  final int identifier;
  final bool isCorrect;
  final dynamic result;
  final StackTrace? stackTrace;

  const ThreadExecutionFinished({required this.identifier, required this.isCorrect, required this.result, this.stackTrace});
}
