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


  String extractOften({int since = 0, int? amount}) {
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

  

  
}
