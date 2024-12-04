import 'dart:convert';
import 'dart:typed_data';

import 'package:maxi_library/maxi_library.dart';
import 'package:http/http.dart' as http;

class OnlineHttpRequester with IHttpRequester {
  final Duration defaultTimeout;
  final String initialUrl;

  int _activeRequest = 0;

  final activeRequests = <Future>[];
  final activePipes = <IPipe>[];

  @override
  bool get isActive => _activeRequest > 0;

  OnlineHttpRequester({required this.defaultTimeout, this.initialUrl = ''});

  @override
  Future<ResponseHttpRequest<T>> executeRequest<T>({
    required HttpMethodType type,
    required String url,
    bool badStatusCodeIsNegativeResult = true,
    Duration? timeout,
    Object? content,
    Map<String, String>? headers,
    Encoding? encoding,
    int? maxSize,
  }) async {
    if (type == HttpMethodType.anyMethod || type == HttpMethodType.webSocket) {
      throw NegativeResult(identifier: NegativeResultCodes.incorrectFormat, message: tr('Incorrect method type, It can\'t be anyMethod or webSocket'));
    }

    _activeRequest += 1;

    late final Future<http.Response> future;
    switch (type) {
      case HttpMethodType.postMethod:
        future = http.post(_makeUrl(url), headers: headers, body: content, encoding: encoding).timeout(timeout ?? defaultTimeout, onTimeout: () => _throwTimeout(url));
        break;
      case HttpMethodType.getMethod:
        future = http.get(_makeUrl(url), headers: headers).timeout(timeout ?? defaultTimeout, onTimeout: () => _throwTimeout(url));
        break;
      case HttpMethodType.deleteMethod:
        future = http.delete(_makeUrl(url), headers: headers, body: content, encoding: encoding).timeout(timeout ?? defaultTimeout, onTimeout: () => _throwTimeout(url));
        break;
      case HttpMethodType.putMethod:
        future = http.put(_makeUrl(url), headers: headers, body: content, encoding: encoding).timeout(timeout ?? defaultTimeout, onTimeout: () => _throwTimeout(url));
        break;
      default:
        throw ArgumentError('Bad method type');
    }

    activeRequests.add(future);
    late final http.Response response;
    try {
      response = await future;
    } finally {
      activeRequests.remove(future);
    }

    if (maxSize != null && volatile(detail: tr('The response from %1 did not return the body size', [url]), function: () => response.contentLength!) > maxSize) {
      throw NegativeResult(
        identifier: NegativeResultCodes.resultInvalid,
        message: tr('The request for %1 would return information of size %2 bytes, but the maximum supported is %3', [url, response.contentLength!, maxSize]),
      );
    }

    if (badStatusCodeIsNegativeResult && response.statusCode >= 400) {
      final error = tryToInterpretError(codeError: response.statusCode, content: response.body, url: url);
      if (T == NegativeResult) {
        return ResponseHttpRequest<T>(content: error as T, codeResult: response.statusCode, url: url);
      } else {
        throw error;
      }
    }

    if (T == Uint8List || T == List<int>) {
      return ResponseHttpRequest<T>(content: response.bodyBytes as T, codeResult: response.statusCode, url: url);
    } else if (T == String || T == dynamic) {
      return ResponseHttpRequest<T>(content: response.body as T, codeResult: response.statusCode, url: url);
    } else if (T.toString() == 'void') {
      return ResponseHttpRequest<T>(content: '' as T, codeResult: response.statusCode, url: url);
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: tr('This type of request only returns string or Uint8List'),
      );
    }
  }

  Uri _makeUrl(String url) {
    if (initialUrl.isEmpty) {
      return Uri.parse(url);
    } else {
      return initialUrl.last == '/' ? Uri.parse('$initialUrl$url') : Uri.parse('$initialUrl/$url');
    }
  }

  Uri _makeWebSocketUrl(String url) {
    final ws = initialUrl.startsWith('https://') || url.startsWith('https://') ? 'wss' : 'ws';
    final completeRoute = _makeUrl(url);

    return Uri.parse('$ws://${completeRoute.authority}${completeRoute.path}');
  }

  Never _throwTimeout(String url) {
    throw NegativeResult(
      identifier: NegativeResultCodes.timeout,
      message: tr('Waited too long for the response from url %1', [url]),
    );
  }

  @override
  Future<IPipe> executeWebSocket({
    required String url,
    bool disableIfNoOneListens = true,
    Map<String, String>? headers,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    final newSocket = await OnlineWebSocket.connect(url: _makeWebSocketUrl(url), disableIfNoOneListens: disableIfNoOneListens, timeout: timeout ?? defaultTimeout);
    activePipes.add(newSocket);
    return newSocket;
  }

  @override
  void close() {
    activeRequests.iterar((x) => x.ignore());
    activePipes.iterar((x) => x.close());

    activeRequests.clear();
    activePipes.clear();
  }
}
