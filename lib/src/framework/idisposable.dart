import 'package:meta/meta.dart';

mixin IDisposable {
  bool _wasDiscarded = false;

  bool get wasDiscarded => _wasDiscarded;

  @protected
  void performObjectDiscard();

  void dispose() {
    if (_wasDiscarded) {
      return;
    }

    performObjectDiscard();
    _wasDiscarded = true;
  }
}
