import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';

enum HttpMethodType { postMethod, getMethod, deleteMethod, putMethod, anyMethod, webSocket }

mixin IHttpRequester {
  bool get isActive;

  Future<ResponseHttpRequest<T>> executeRequest<T>({
    required HttpMethodType type,
    required String url,
    bool badStatusCodeIsNegativeResult = true,
    Duration? timeout,
    Object? content,
    Map<String, String>? headers,
    Encoding? encoding,
    int? maxSize,
  });

  Future<IPipe> executeWebSocket({
    required String url,
    bool disableIfNoOneListens = true,
    Map<String, String>? headers,
    Encoding? encoding,
    Duration? timeout,
  });

  void close();

  Future<T> executeRequestWithReflectResult<T>({
    required HttpMethodType type,
    required String url,
    Duration? timeout,
    Object? content,
    Map<String, String>? headers,
    Encoding? encoding,
    int? maxSize,
    T Function(String)? buildFunction,
    bool badStatusCodeIsNegativeResult = true,
  }) async {
    if (buildFunction != null) {
      ReflectionManager.getReflectionEntity(T); //<--- check that it exists before executing the request
    }
    //final reflector =
    final result = await executeRequest<String>(
      type: type,
      url: url,
      timeout: timeout,
      content: content,
      encoding: encoding,
      headers: headers,
      maxSize: maxSize,
      badStatusCodeIsNegativeResult: badStatusCodeIsNegativeResult,
    );

    if (buildFunction == null) {
      return ReflectionManager.getReflectionEntity(T).interpretationFromJson(rawJson: result.content, tryToCorrectNames: true) as T;
    } else {
      return buildFunction(result.content);
    }
  }

  Future<List<T>> executeRequestWithReflectList<T>({
    required HttpMethodType type,
    required String url,
    Duration? timeout,
    Object? content,
    Map<String, String>? headers,
    Encoding? encoding,
    int? maxSize,
    List<T> Function(String)? buildFunction,
    bool badStatusCodeIsNegativeResult = true,
  }) async {
    if (buildFunction != null) {
      ReflectionManager.getReflectionEntity(T); //<--- check that it exists before executing the request
    }
    //final reflector =
    final result = await executeRequest<String>(
      type: type,
      url: url,
      timeout: timeout,
      content: content,
      encoding: encoding,
      headers: headers,
      maxSize: maxSize,
      badStatusCodeIsNegativeResult: badStatusCodeIsNegativeResult,
    );

    if (buildFunction == null) {
      return ReflectionManager.getReflectionEntity(T).interpretJsonAslist<T>(rawText: result.content, tryToCorrectNames: true);
    } else {
      return buildFunction(result.content);
    }
  }

  Future<Map<String, dynamic>> executeRequestReceivingJsonObject({
    required HttpMethodType type,
    required String url,
    Duration? timeout,
    Object? content,
    Map<String, String>? headers,
    Encoding? encoding,
    int? maxSize,
    bool badStatusCodeIsNegativeResult = true,
  }) async {
    final rawContent = await executeRequest<String>(
      type: type,
      url: url,
      badStatusCodeIsNegativeResult: badStatusCodeIsNegativeResult,
      content: content,
      encoding: encoding,
      headers: headers,
      maxSize: maxSize,
      timeout: timeout,
    );

    final rawJson = volatile(detail: Oration(message: 'Expected return of a json object in request %1', textParts: [url]), function: () => json.decode(rawContent.content));
    return volatile(detail: Oration(message: 'Expected json object in request %1', textParts: [url]), function: () => rawJson as Map<String, dynamic>);
  }

  NegativeResult tryToInterpretError({required String content, required int codeError, required String url}) {
    if (!content.startsWith('{') || !content.endsWith('}')) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(message: 'The server %1 responded to a request with an error, but did not send a result in json', textParts: [url]),
      );
    }

    final rawJson = volatile(
      detail: Oration(message: 'The server %1 responded to a request with an error, but it sent a corrupt json', textParts: [url]),
      function: () => json.decode(content) as Map<String, dynamic>,
    );

    return NegativeResult.interpret(values: rawJson, checkTypeFlag: true);
  }
}
