import 'package:maxi_library/maxi_library.dart';

class Description {
  final TranslatableText text;

  const Description(this.text);

  static TranslatableText searchDescription({required List annotations, TranslatableText? alternative}) {
    final formal = annotations.selectByType<Description>();
    if (formal != null) {
      return formal.text;
    }

    return alternative ?? const TranslatableText(message: '');
  }
}
