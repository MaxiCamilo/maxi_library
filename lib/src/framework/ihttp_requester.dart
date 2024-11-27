import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';

enum HttpMethodType { postMethod, getMethod, deleteMethod, putMethod, anyMethod, webSocket }

mixin IHttpRequester {
  bool get isActive;

  Future<T> executeRequest<T>({
    required HttpMethodType type,
    required String url,
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
    );

    if (buildFunction == null) {
      return ReflectionManager.getReflectionEntity(T).interpretationFromJson(rawJson: result, tryToCorrectNames: true) as T;
    } else {
      return buildFunction(result);
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
    );

    if (buildFunction == null) {
      return ReflectionManager.getReflectionEntity(T).interpretJsonAslist<T>(rawText: result, tryToCorrectNames: true);
    } else {
      return buildFunction(result);
    }
  }
}
