import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/utils/storage/dio/http_request_interceptor.dart';

import '../../../constants/endpoint.dart';
import '../../../constants/enum.dart';

part 'network_module.g.dart';

// Must be top-level function
_parseAndDecode(String respose) {
  try {
    return jsonDecode(respose);
  } catch (e) {
    return respose;
  }
}

parseJson(String text) => compute(_parseAndDecode, text);

class DioNetworkModule {
  Dio provideDio({
    required String baseUrl,
    int? port,
    bool addPort = true,
    required AuthType authType,
    HiveCacheStore? hiveCacheStore,
    required Ref ref,
  }) {
    final cacheOptions = CacheOptions(
      store: hiveCacheStore,
      policy: CachePolicy.refreshForceCache,
      priority: CachePriority.normal,
      maxStale: const Duration(days: 14),
    );

    final dio = Dio();

    dio.transformer = BackgroundTransformer()..jsonDecodeCallback = parseJson;

    dio
      ..options.baseUrl = Endpoints.baseApi(
        baseUrl: baseUrl,
        port: port,
        addPort: addPort,
      )
      ..options.connectTimeout = Endpoints.connectionTimeout
      ..options.receiveTimeout = Endpoints.receiveTimeout
      ..options.contentType = Headers.jsonContentType
      ..interceptors.add(DioCacheInterceptor(options: cacheOptions))
      ..interceptors.add(HttpRequestInterceptor(ref, dio))
      ..interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 100,
          enabled: kDebugMode,
        ),
      );

    return dio;
  }
}

@riverpod
DioNetworkModule networkModule(ref) => DioNetworkModule();
