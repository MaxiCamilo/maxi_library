class TranslatableText {
  final String text;
  final int pointerPosition;

  const TranslatableText(this.text, {this.pointerPosition = 0});

  TranslatableText replace({required int position, required String newText}) {
    final generatedText = text.replaceAll('%$position', newText);
    return TranslatableText(generatedText, pointerPosition: pointerPosition);
  }

  TranslatableText append(String newText) {
    final generatedText = text.replaceAll('%$pointerPosition', newText);
    final newPointerPosition = pointerPosition + 1;
    return TranslatableText(generatedText, pointerPosition: newPointerPosition);
  }

  
}
