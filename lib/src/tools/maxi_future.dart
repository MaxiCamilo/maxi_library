import 'dart:async';

class MaxiFuture<T> implements Future<T> {
  final Future<T> _inner;
  bool _wasAccessed = false;
  bool _wasIgnored = false;
  void Function(MaxiFuture<T>)? onIgnore;
  void Function(MaxiFuture<T>)? onComplete;

  bool get wasAccessed => _wasAccessed;
  bool get wasIgnored => _wasIgnored;

  MaxiFuture(this._inner, {this.onIgnore, this.onComplete});

  MaxiFuture makeChild({required void Function(MaxiFuture<T>) onIgnore}) {
    late final MaxiFuture<T> newFuture;
    newFuture = MaxiFuture<T>(this, onIgnore: (_) {
      newFuture.ignore();
      ignore();
      //onIgnore(newFuture);
    });

    return newFuture;
  }

  @override
  Stream<T> asStream() {
    _wasAccessed = true;
    return _inner.asStream();
  }

  @override
  Future<T> catchError(Function onError, {bool Function(Object)? test}) {
    _wasAccessed = true;
    return _inner.catchError(onError, test: test);
  }

  @override
  Future<S> then<S>(FutureOr<S> Function(T) onValue, {Function? onError}) {
    _wasAccessed = true;

    return _inner.then(onValue, onError: onError);
  }

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) {
    _wasAccessed = true;
    return _inner.timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) {
    _wasAccessed = true;
    if (onComplete != null) {
      onComplete!(this);
    }
    return _inner.whenComplete(action);
  }

  void ignore() {
    if (_wasIgnored) {
      return;
    }
    _wasIgnored = true;
    _inner.ignore();
    if (onIgnore != null) {
      onIgnore!(this);
    }
  }
}
