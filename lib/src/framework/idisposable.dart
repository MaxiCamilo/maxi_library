import 'package:maxi_library/maxi_library.dart';
import 'package:meta/meta.dart';

mixin IDisposable {
  bool _wasDiscarded = false;

  bool get wasDiscarded => _wasDiscarded;

  MaxiCompleter? _onDisposeCompleter;

  @protected
  void performObjectDiscard();

  void dispose() {
    maxi_dispose();
  }

  Future<dynamic> get onDispose {
    _onDisposeCompleter ??= MaxiCompleter();
    return _onDisposeCompleter!.future;
  }

  // ignore: non_constant_identifier_names
  void maxi_dispose() {
    if (_wasDiscarded) {
      return;
    }

    performObjectDiscard();
    _onDisposeCompleter?.completeIfIncomplete();
    _onDisposeCompleter = null;
    _wasDiscarded = true;
  }
}
