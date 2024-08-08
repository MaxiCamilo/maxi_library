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


  String extractOften({int since = 0, int? count}) {
    final buffer = StringBuffer();
    if (count == null || count >= length) {
      for (int i = since; i < length; i++) {
        buffer.write(this[i]);
      }
    } else {
      for (int i = since; i < since + count && i < length; i++) {
        buffer.write(this[i]);
      }
    }

    return buffer.toString();
  }
}
