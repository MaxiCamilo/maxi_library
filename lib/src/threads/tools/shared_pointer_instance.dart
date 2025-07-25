import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/singletons/shared_pointer_manager.dart';

class SharedPointerInstance<T> with IDisposable, PaternalFunctionality {
  final T item;

  late final int _identifier;

  SharedPointerInstance({required this.item}) {
    _identifier = SharedPointerManager.singleton.addItem(item);

    if (item is IDisposable) {
      (item as IDisposable).onDispose.whenComplete(dispose);
    }
  }

  SharedPointer<T> createPointer() => SharedPointer<T>(
        threadID: ThreadManager.instance is IFakeThread ? -1 : ThreadManager.instance.threadID,
        identifier: _identifier,
      );

  @override
  void performObjectDiscard() {
    super.performObjectDiscard();
    SharedPointerManager.singleton.removeItem(identifier: _identifier);
  }
}
