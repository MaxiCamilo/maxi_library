import 'package:maxi_library/maxi_library.dart';

class FixedSemaphore<T> {
  final Future<T> Function() reservedFunction;

  final _semaphore = Semaphore();

  FixedSemaphore({required this.reservedFunction});

  Future<T> execute() => _semaphore.execute(function: reservedFunction);
}
