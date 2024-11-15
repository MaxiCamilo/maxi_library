import 'package:maxi_library/maxi_library.dart';

mixin StreamState<S, R> {}

mixin FunctionalStream<S, R> {
  Stream<StreamState<S, R>> execute();
}

typedef StateTexts<T> = StreamState<TranslatableText, T>;
typedef StateTextsVoid = StreamState<TranslatableText, void>;

typedef StreamStateTexts<T> = Stream<StreamState<TranslatableText, T>>;
typedef StreamStateTextsVoid = Stream<StreamState<TranslatableText, void>>;
