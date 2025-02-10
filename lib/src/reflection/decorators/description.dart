import 'package:maxi_library/maxi_library.dart';

class Description {
  final Oration text;

  const Description(this.text);

  static Oration searchDescription({required List annotations, Oration? alternative}) {
    final formal = annotations.selectByType<Description>();
    if (formal != null) {
      return formal.text;
    }

    return alternative ?? const Oration(message: '');
  }
}
