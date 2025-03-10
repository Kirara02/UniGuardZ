import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/constants/endpoint.dart';
import 'package:ugz_app/src/utils/service/geolocation_tracking_service.dart';

part 'background_network_module.g.dart';

// Must be top-level function
_parseAndDecode(String response) {
  try {
    return jsonDecode(response);
  } catch (e) {
    return response;
  }
}

parseJson(String text) => compute(_parseAndDecode, text);

class DioBackgroundNetworkModule {
  Dio provideDio({
    required String baseUrl,
    int? port,
    bool addPort = true,
  }) {
    final dio = Dio();
    dio.transformer = BackgroundTransformer();
    (dio.transformer as BackgroundTransformer).jsonDecodeCallback = parseJson;

    dio
      ..options.baseUrl = Endpoints.baseApi(
        baseUrl: baseUrl,
        port: port,
        addPort: addPort,
      )
      ..options.connectTimeout = Endpoints.connectionTimeout
      ..options.receiveTimeout = Endpoints.receiveTimeout
      ..interceptors.add(
        InterceptorsWrapper(
          onError: (DioException err, ErrorInterceptorHandler handler) {
            if (err.response?.statusCode == 401) {
              GeolocationTrackingService().stopService();
            }
          },
        ),
      )
      ..interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 100,
        enabled: kDebugMode,
      ));

    return dio;
  }
}

@riverpod
DioBackgroundNetworkModule backgroundNetworkModule(ref) => DioBackgroundNetworkModule();