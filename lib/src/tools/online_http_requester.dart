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
  Future<T> executeRequest<T>({
    required HttpMethodType type,
    required String url,
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

    if (T == Uint8List || T == List<int>) {
      return response.bodyBytes as T;
    } else if (T == String || T == dynamic) {
      return response.body as T;
    } else if (T.toString() == 'void') {
      return '' as T;
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: tr('This type of request only returns string or Uint8List'),
      );
    }
  }

  Uri _makeUrl(String url) {
    if (initialUrl.isEmpty) {
      return initialUrl.last == '/' ? Uri.parse('$initialUrl$url') : Uri.parse('$initialUrl/$url');
    } else {
      return Uri.parse(url);
    }
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
    final newSocket = await OnlineWebSocket.connect(url: _makeUrl(url), disableIfNoOneListens: disableIfNoOneListens, timeout: timeout ?? defaultTimeout);
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
