import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:maxi_library/maxi_library.dart';
import 'package:http/http.dart' as http;

class OnlineHttpRequester with IDisposable, PaternalFunctionality, IHttpRequester {
  final Duration defaultTimeout;
  final String initialUrl;
  final Map<String, String> initialHeaders;

  int _activeRequest = 0;

  final activeRequests = <Future>[];
  final activePipes = <IChannel>[];

  StreamController<NegativeResult>? _errorStreamController;

  Stream<NegativeResult> get errorStream async* {
    checkIfDispose();
    _errorStreamController ??= createEventController<NegativeResult>(isBroadcast: true);

    yield* _errorStreamController!.stream;
  }

  @override
  bool get isActive => _activeRequest > 0;

  OnlineHttpRequester({required this.defaultTimeout, this.initialUrl = '', Map<String, String>? headers}) : initialHeaders = headers ?? {};

  void defineBearerAuthorization({required String bearerContent}) {
    initialHeaders['Authorization'] = 'Bearer $bearerContent';
  }

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
    resurrectObject();
    if (type == HttpMethodType.anyMethod || type == HttpMethodType.webSocket) {
      throw NegativeResult(identifier: NegativeResultCodes.incorrectFormat, message: Oration(message: 'Incorrect method type, It can\'t be anyMethod or webSocket'));
    }

    _activeRequest += 1;

    late final Future<http.Response> future;

    Map<String, String>? totalHeaders;

    if (headers != null) {
      totalHeaders ??= <String, String>{};
      totalHeaders.addAll(headers);
    }

    if (initialHeaders.isNotEmpty) {
      totalHeaders ??= <String, String>{};
      totalHeaders.addAll(initialHeaders);
    }

    switch (type) {
      case HttpMethodType.postMethod:
        future = http.post(_makeUrl(url), headers: totalHeaders, body: content, encoding: encoding).timeout(timeout ?? defaultTimeout, onTimeout: () => _throwTimeout(url));
        break;
      case HttpMethodType.getMethod:
        future = http.get(_makeUrl(url), headers: totalHeaders).timeout(timeout ?? defaultTimeout, onTimeout: () => _throwTimeout(url));
        break;
      case HttpMethodType.deleteMethod:
        future = http.delete(_makeUrl(url), headers: totalHeaders, body: content, encoding: encoding).timeout(timeout ?? defaultTimeout, onTimeout: () => _throwTimeout(url));
        break;
      case HttpMethodType.putMethod:
        future = http.put(_makeUrl(url), headers: totalHeaders, body: content, encoding: encoding).timeout(timeout ?? defaultTimeout, onTimeout: () => _throwTimeout(url));
        break;
      default:
        throw ArgumentError('Bad method type');
    }

    activeRequests.add(future);
    late final http.Response response;
    try {
      response = await future;
    } on http.ClientException catch (ex, st) {
      final error = NegativeResult(
        identifier: NegativeResultCodes.externalFault,
        message: Oration(
          message: 'A request to server %1 failed with the following error: %2',
          textParts: [initialUrl, ex.message],
        ),
        cause: ex,
        stackTrace: st.toString(),
      );
      _errorStreamController?.addIfActive(error);

      throw error;
    } finally {
      activeRequests.remove(future);
    }

    if (maxSize != null && volatile(detail: Oration(message: 'The response from %1 did not return the body size', textParts: [url]), function: () => response.contentLength!) > maxSize) {
      final sizeError = NegativeResult(
        identifier: NegativeResultCodes.resultInvalid,
        message: Oration(message: 'The request for %1 would return information of size %2 bytes, but the maximum supported is %3', textParts: [url, response.contentLength!, maxSize]),
      );
      _errorStreamController?.addErrorIfActive(sizeError);
      throw sizeError;
    }

    if (badStatusCodeIsNegativeResult && response.statusCode >= 400) {
      final error = IHttpRequester.tryToInterpretError(codeError: response.statusCode, content: response.body, url: url);
      if (T == NegativeResult) {
        return ResponseHttpRequest<T>(content: error as T, codeResult: response.statusCode, url: url);
      } else {
        _errorStreamController?.addIfActive(error);
        throw error;
      }
    }

    if (T == Uint8List || T == List<int>) {
      return ResponseHttpRequest<T>(content: response.bodyBytes as T, codeResult: response.statusCode, url: url);
    } else if (T == String || T == dynamic) {
      return ResponseHttpRequest<T>(content: response.body as T, codeResult: response.statusCode, url: url);
    } else if (T == Map<String, dynamic>) {
      return ResponseHttpRequest<T>(content: ConverterUtilities.interpretToObjectJson(text: response.body, extra: Oration(message: 'from the server')) as T, codeResult: response.statusCode, url: url);
    } else if (T.toString() == 'void') {
      return ResponseHttpRequest<T>(content: '' as T, codeResult: response.statusCode, url: url);
    } else {
      final contentError = NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(message: 'This type of request only returns string or Uint8List'),
      );
      _errorStreamController?.addErrorIfActive(contentError);
      throw contentError;
    }
  }

  Uri _makeUrl(String url) {
    if (initialUrl.isEmpty) {
      return Uri.parse(url);
    } else {
      return initialUrl.last == '/' ? Uri.parse('$initialUrl$url') : Uri.parse('$initialUrl/$url');
    }
  }

  Uri _makeWebSocketUrl(String url, Map<String, String> queryParameters) {
    final ws = initialUrl.startsWith('https://') || url.startsWith('https://') ? 'wss' : 'ws';
    final completeRoute = _makeUrl(url);

    if (queryParameters.isEmpty) {
      return Uri.parse('$ws://${completeRoute.authority}${completeRoute.path}');
    } else {
      return Uri.parse('$ws://${completeRoute.authority}${completeRoute.path}?${queryParameters.entries.map((x) => '${x.key}=${x.value}').join('&')}');
    }
    /*return Uri(
      scheme: ws,
      host: completeRoute.authority.replaceAll('localhost', '127.0.0.1'),
      path: completeRoute.path,
      queryParameters: queryParameters,
    );*/
  }

  Never _throwTimeout(String url) {
    throw NegativeResult(
      identifier: NegativeResultCodes.timeout,
      message: Oration(message: 'Waited too long for the response from url %1', textParts: [url]),
    );
  }

  @override
  Future<IChannel> executeWebSocket({
    required String url,
    Map<String, String> queryParameters = const {},
    bool disableIfNoOneListens = true,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    resurrectObject();
    final newSocket = await OnlineWebSocket.connect(
      url: _makeWebSocketUrl(url, queryParameters),
      disableIfNoOneListens: disableIfNoOneListens,
      timeout: timeout ?? defaultTimeout,
    );
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
