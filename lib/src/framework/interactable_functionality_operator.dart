import 'package:maxi_library/maxi_library.dart';

mixin InteractableFunctionalityOperator<I, R> on IDisposable {
  Stream<I> get itemStream;
  int get identifier;

  void start();
  void cancel();
  MaxiFuture<R> waitResult({void Function(I item)? onItem});
}

mixin InteractableFunctionalityExecutor<I, R> on IDisposable, PaternalFunctionality {
  int get identifier;
  void sendItem(I item);
  void checkActivity();
  Future<void> delayed(Duration time);
  Future<void> sendItemAsync(I item) async {
    await continueOtherFutures();
    checkActivity();
    sendItem(item);
    await continueOtherFutures();
    checkActivity();
  }
}
