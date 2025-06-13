import 'dart:math' show Random;

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
          return dio.extractFrom(since: dio.length - quantityZeros);
        } else {
          return dio.extractFrom(since: 0, amount: quantityZeros);
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

  static String generateCommand<T>({
    required Iterable<T> list,
    String Function(T)? function,
    String character = ',',
  }) {
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

  static List<(String, String)> groupAccordingToOptions({required String text, required List<String> options}) {
    final list = <(String, String)>[];
    final buffer = StringBuffer();

    String prefix = '';

    int i = 0;
    while (i < text.length) {
      final coincidence = options.selectItem((x) => text.startsWith(x, i));
      if (coincidence == null) {
        buffer.write(text[i]);
        i += 1;
        continue;
      }

      list.add((prefix, buffer.toString()));
      buffer.clear();

      prefix = coincidence;
      i += prefix.length;
    }

    if (buffer.isNotEmpty) {
      list.add((prefix, buffer.toString()));
    }

    if (list.length > 1 && list.first.$1 == '' && list.first.$2 == '') {
      list.removeAt(0);
    }

    return list;
  }

  static List<String> splitAccordingToOptions({required String text, required List<String> options, required bool addOptionsToResult}) {
    final list = <String>[];
    final buffer = StringBuffer();

    int i = 0;
    while (i < text.length) {
      final coincidence = options.selectItem((x) => text.startsWith(x, i));
      if (coincidence == null) {
        buffer.write(text[i]);
        i += 1;
      } else {
        if (buffer.isNotEmpty) {
          list.add(buffer.toString());
          buffer.clear();
        }
        if (addOptionsToResult) {
          list.add(coincidence);
        }
        i += coincidence.length;
      }
    }

    if (buffer.isNotEmpty) {
      list.add(buffer.toString());
    }

    return list;
  }

  static String parseSnakeCaseToCamelCase(String text) {
    if (text.isEmpty || (!text.contains('_') && !text.contains(' '))) {
      return text.toLowerCase();
    }

    final parts = text.split('_').expand((x) => x.split(' ')).toList(growable: false);
    String camelCase = parts.first.toLowerCase();
    for (int i = 1; i < parts.length; i++) {
      if (parts[i].isEmpty) {
        continue;
      } else if (parts[i].length == 1) {
        camelCase += parts[i][0].toUpperCase();
      } else {
        camelCase += parts[i][0].toUpperCase() + parts[i].substring(1).toLowerCase();
      }
    }

    return camelCase;
  }

  static String formatDate(
    DateTime date, {
    bool putWeekNames = true,
    bool useShortNames = true,
    bool putDateNames = true,
    bool putYears = true,
    bool putTime = true,
    bool putSeconds = true,
    String dateSeparator = '/',
    String timeSeparator = ':',
  }) {
    final buffer = StringBuffer();

    if (date.isUtc) {
      date = date.toLocal();
    }
    //Monday Tuesday Wednesday Thursday Friday Saturday Sunday
    if (putDateNames) {
      if (putWeekNames) {
        switch (date.weekday) {
          case DateTime.monday:
            buffer.write(useShortNames ? const Oration(message: 'Mon').toString() : const Oration(message: 'Monday').toString());
            break;
          case DateTime.tuesday:
            buffer.write(useShortNames ? const Oration(message: 'Tue').toString() : const Oration(message: 'Tuesday').toString());
            break;
          case DateTime.wednesday:
            buffer.write(useShortNames ? const Oration(message: 'Wed').toString() : const Oration(message: 'Wednesday').toString());
            break;
          case DateTime.thursday:
            buffer.write(useShortNames ? const Oration(message: 'Thu').toString() : const Oration(message: 'Thursday').toString());
            break;
          case DateTime.friday:
            buffer.write(useShortNames ? const Oration(message: 'Fri').toString() : const Oration(message: 'Friday').toString());
            break;
          case DateTime.saturday:
            buffer.write(useShortNames ? const Oration(message: 'Sat').toString() : const Oration(message: 'Saturday').toString());
            break;
          case DateTime.sunday:
            buffer.write(useShortNames ? const Oration(message: 'Sun').toString() : const Oration(message: 'Sunday').toString());
            break;
        }

        buffer.write(' ');
      }

      buffer.write('${zeroFill(value: date.day, quantityZeros: 2)}$dateSeparator${zeroFill(value: date.month, quantityZeros: 2)}');
      if (putYears) {
        buffer.write('$dateSeparator${date.year}');
      }

      if (putTime) {
        buffer.write(' ');
      }
    }

    if (putTime) {
      buffer.write('${zeroFill(value: date.hour, quantityZeros: 2)}$timeSeparator${zeroFill(value: date.minute, quantityZeros: 2)}');
      if (putSeconds) {
        buffer.write('$timeSeparator${zeroFill(value: date.second, quantityZeros: 2)}');
      }
    }

    return buffer.toString();
  }

  static bool checkContainsOnlyNumbers(String str) {
    final numericRegex = RegExp(r'^-?\d+$');
    return numericRegex.hasMatch(str);
  }

  static List<String> parseQuotedTexts(String input) {
    final RegExp exp = RegExp(r'"(.*?)"');
    return exp.allMatches(input).map((match) => match.group(1)?.trim() ?? '').toList();
  }

  static String createRandomText(int longitud) {
    const characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(longitud, (index) => characters[random.nextInt(characters.length)]).join();
  }
}
