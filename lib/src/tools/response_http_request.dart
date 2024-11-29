class ResponseHttpRequest<T> {
  final String url;
  final int codeResult;

  final T content;

  const ResponseHttpRequest({required this.url, required this.codeResult, required this.content});
}
