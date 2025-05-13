import 'package:meta/meta.dart';

mixin IDisposable {
  bool _wasDiscarded = false;

  bool get wasDiscarded => _wasDiscarded;

  @protected
  void performObjectDiscard();

  void dispose() {
    maxi_dispose();
  }

  // ignore: non_constant_identifier_names
  void maxi_dispose() {
    if (_wasDiscarded) {
      return;
    }

    performObjectDiscard();
    _wasDiscarded = true;
  }
}
