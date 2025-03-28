extension ExtensionsString on String {
  String get first {
    if (isEmpty) {
      return '';
    } else {
      return this[0];
    }
  }

  String get last {
    if (isEmpty) {
      return '';
    } else {
      return this[length - 1];
    }
  }

  String extractFrom({int since = 0, int? amount}) {
    final buffer = StringBuffer();
    if (amount == null || amount >= length) {
      for (int i = since; i < length; i++) {
        buffer.write(this[i]);
      }
    } else {
      for (int i = since; i < since + amount && i < length; i++) {
        buffer.write(this[i]);
      }
    }

    return buffer.toString();
  }

  String extractInverselyFrom({int? since, int? amount}) {
    final buffer = <String>[];
    since ??= isNotEmpty ? length - 1 : 0;

    if (since >= length) {
      since = length - 1;
    }

    if (amount == null || amount >= length) {
      for (int i = since; i >= 0; i--) {
        buffer.add(this[i]);
      }
    } else {
      for (int i = since; i >= 0 && buffer.length < amount; i--) {
        buffer.add(this[i]);
      }
    }

    return buffer.reversed.join();
  }

  int searchTextInCommand({required String textToFind, bool avoidQuotes = false, List<String> quotes = const ['\'', '"', '`']}) {
    String? selectedQuote;

    for (int i = 0; i < length; i++) {
      if (avoidQuotes) {
        if (selectedQuote != null && selectedQuote == this[i]) {
          if (i > 0 && this[i - 1] == '\\') {
            continue;
          }
          selectedQuote = null;
          continue;
        } else if (selectedQuote == null && quotes.contains(this[i])) {
          if (i > 0 && this[i - 1] == '\\') {
            continue;
          }
          selectedQuote = this[i];
        }
      }

      if (selectedQuote == null && startsWith(textToFind, i)) {
        return i;
      }
    }

    return -1;
  }

  int searchTextInQuotes({required String textToFind, List<String> quotes = const ['\'', '"', '`']}) {
    String? selectedQuote;

    for (int i = 0; i < length; i++) {
      if (selectedQuote != null && selectedQuote == this[i]) {
        if (i > 0 && this[i - 1] == '\\') {
          continue;
        }
        selectedQuote = null;
        continue;
      } else if (selectedQuote == null && quotes.contains(this[i])) {
        if (i > 0 && this[i - 1] == '\\') {
          continue;
        }
        selectedQuote = this[i];
      } else if (selectedQuote != null && startsWith(textToFind, i)) {
        return i;
      }
    }

    return -1;
  }

  String replaceTextFromPosition({required int start, required String newText, int skipLength = 0}) {
    if (start >= length) {
      throw ArgumentError('Invalid range ($start >= $length length)');
    }

    final before = substring(0, start);
    final after = extractFrom(since: start + skipLength);

    return before + newText + after;
  }

  Iterable<String> divideByLength({required int length}) sync* {
    final buffer = StringBuffer();

    for (int i = 0; i < this.length; i++) {
      buffer.write(this[i]);
      if (buffer.length >= length) {
        yield buffer.toString();
        buffer.clear();
      }
    }

    if (buffer.isNotEmpty) {
      yield buffer.toString();
    }
  }

  Iterable<String> divideByLengthWithChar({required int limit, List<String> characters = const ['\n', '\\\n', '.', ',', ' ']}) sync* {
    if (length > limit) {
      if (characters.isEmpty) {
        yield* divideByLength(length: limit);
        return;
      }

      final separators = characters.toList();
      final firstSeparator = separators.removeAt(0);

      final slit = split(firstSeparator);
      final buffer = StringBuffer();

      for (int i = 0; i < slit.length; i++) {
        final item = slit[i];
        if (item.length > limit) {
          yield* item.divideByLengthWithChar(limit: limit, characters: separators);
        } else if (buffer.length + (i != slit.length - 1 ? 1 : 0) + item.length > limit) {
          final cutLength = limit - (buffer.length + (i == slit.length - 1 ? 1 : 0));

          if (cutLength > 0) {
            final firstPart = item.extractFrom(since: 0, amount: cutLength);
            final secondPart = item.extractFrom(since: cutLength).trimLeft();
            buffer.write(firstPart);
            yield buffer.toString();
            buffer.clear();
            buffer.write(secondPart);
          } else {
            yield buffer.toString();
            buffer.clear();
            buffer.write(item);
          }

          if (i != slit.length - 1) {
            buffer.write(firstSeparator);
          }
        } else {
          buffer.write(item);
          if (i != slit.length - 1) {
            buffer.write(firstSeparator);
          }
        }
      }

      if (buffer.isNotEmpty) {
        yield buffer.toString();
      }
    } else {
      yield this;
    }
  }

  Iterable<String> asIterable({int start = 0, int? end, bool inverse = false}) sync* {
    end ??= length - 1;

    if (inverse) {
      if (end >= length) {
        end = length - 1;
      }

      for (int i = end; i >= start && i >= 0; i--) {
        yield this[i];
      }
    } else {
      for (int i = start; i <= end && i < length; i++) {
        yield this[i];
      }
    }
  }

  Iterable<(int, String)> asPositionalIterable({int start = 0, int? end, bool inverse = false}) sync* {
    end ??= length - 1;

    if (inverse) {
      if (end >= length) {
        end = length - 1;
      }

      for (int i = end; i >= start && i >= 0; i--) {
        yield (i, this[i]);
      }
    } else {
      for (int i = start; i <= end && i <= length; i++) {
        yield (i, this[i]);
      }
    }
  }

  String removeQuotes({List<String> quotes = const ['\'', '"', '`']}) {
    late final String selectedQuote;
    int i = -1;

    for (final (pos, char) in asPositionalIterable()) {
      if (quotes.contains(char)) {
        i = pos;
        selectedQuote = char;
        break;
      }
    }

    if (i == -1) {
      return this;
    }

    final buffer = StringBuffer();

    for (final (pos, char) in asPositionalIterable(start: i + 1)) {
      if (char == selectedQuote && !(pos - 1 != i && this[pos - 1] == '\\')) {
        break;
      } else {
        buffer.write(char);
      }
    }

    return buffer.toString();
  }

  String toFirstInCapitalLetter() {
    if (isEmpty) {
      return '';
    }
    return '${first.toUpperCase()}${extractFrom(since: 1)}';
  }

  String toFirstInLowercase() {
    if (isEmpty) {
      return '';
    }
    return '${first.toLowerCase()}${extractFrom(since: 1)}';
  }

  String extractSinceItStarted({
    required List<String> options,
    int start = 0,
    int? end,
    bool inclueOptionInExtraction = true,
  }) {
    if (isEmpty) {
      return '';
    }

    for (int i = start; i < length || (end != null && i <= end); i++) {
      for (final opt in options) {
        if (startsWith(opt, i)) {
          return extractFrom(since: inclueOptionInExtraction ? i : i + opt.length);
        }
      }
    }

    return this;
  }

  String extractUpToOption({
    required List<String> options,
    int start = 0,
    int? end,
    bool inclueOptionInExtraction = true,
  }) {
    if (isEmpty) {
      return '';
    }

    for (int i = start; i < length || (end != null && i <= end); i++) {
      for (final opt in options) {
        if (startsWith(opt, i)) {
          return extractFrom(since: start, amount: inclueOptionInExtraction ? i + opt.length : i);
        }
      }
    }

    return this;
  }

  
  
}
