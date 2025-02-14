import 'package:maxi_library/maxi_library.dart';

typedef StateTexts<T> = StreamState<Oration, T>;
typedef StateTextsVoid = StreamState<Oration, void>;

typedef StreamStateTexts<T> = Stream<StreamState<Oration, T>>;
typedef StreamStateTextsVoid = Stream<StreamState<Oration, void>>;

mixin StreamState<S, R> {}

mixin FunctionalStream<S, R> {
  Stream<StreamState<S, R>> execute();
}
