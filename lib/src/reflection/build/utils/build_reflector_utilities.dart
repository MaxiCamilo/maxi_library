import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/build/detected/annotation_detected.dart';

mixin BuildReflectorUtilities {
  static String removeQuotesText({required String type, required String raw}) {
    if (type != 'String' && type != 'dynamic') {
      return raw;
    }

    return raw.removeQuotes();
  }

  static String makeAnnotationsScript({required List<AnnotationDetected> anotations}) {
    final buffer = StringBuffer('const [');

    if (anotations.isNotEmpty) {
      buffer.write(TextUtilities.generateCommand(list: anotations.map((x) => x.rawText)));
    }

    buffer.write(']');

    return buffer.toString();
  }
}
