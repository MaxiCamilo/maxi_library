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

  static String generateCommand<T>({required Iterable<T> list, String Function(T)? function, String character = ','}) {
    final buffer = StringBuffer();
    final convertido = list.map<String>((e) => function == null ? e.toString() : function(e)).toList();
    final ultimo = convertido.length - 1;

    for (int i = 0; i < convertido.length; i++) {
      buffer.write(convertido[i]);
      if (i != ultimo) {
        buffer.write(character);
      }
    }

    return buffer.toString();
  }
}
