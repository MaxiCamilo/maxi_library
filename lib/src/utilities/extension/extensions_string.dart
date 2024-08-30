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
}
