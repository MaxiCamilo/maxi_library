import 'package:maxi_library/maxi_library.dart';

mixin TextUtilities {
  static String zeroFill({
    required dynamic value,
    required int quantityZeros,
    bool cutIfExceeds = true,
    bool cutFromTheEnd = true,
  }) {
    final dio = value is double ? value.toInt().toString() : value.toString();

    if (dio.length > quantityZeros) {
      if (cutIfExceeds) {
        if (cutFromTheEnd) {
          return dio.extractOften(since: dio.length - quantityZeros);
        } else {
          return dio.extractOften(since: 0, amount: quantityZeros);
        }
      } else {
        return dio;
      }
    }

    final buffer = StringBuffer();
    for (int i = dio.length; i < quantityZeros; i++) {
      buffer.write('0');
    }

    buffer.write(dio);
    return buffer.toString();
  }
}
