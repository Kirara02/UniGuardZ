import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../dio_error_util.dart';
import 'api_response.dart';
import 'api_response_handler.dart';

typedef ResponseDecoderCallBack<DecoderType> = DecoderType Function(dynamic);

class DioClient {
  final Dio dio;
  DioClient({required this.dio});

  /// Handy method to make http GET request with ApiResponse
  /// Handy method to make http GET request with ApiResponse
  Future<ApiResponse<T>> getApiResponse<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    JsonConverter<T>? converter,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Configure Dio to not throw on error status codes
      final requestOptions = options ?? Options();
      requestOptions.validateStatus = (status) => true;

      final response = await dio.get(
        url,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      // For successful responses, parse as normal
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (converter != null) {
          return ApiResponseHandler.handleResponse<T>(response.data, converter);
        }
      }

      // For error responses, create an error ApiResponse
      if (response.data is Map<String, dynamic>) {
        // Try to extract error message from response
        final errorMessage =
            response.data['message'] as String? ??
            response.data['error']?['details'] as String? ??
            'Request failed with status: ${response.statusCode}';

        return ApiResponse<T>(
          success: false,
          message: errorMessage,
          meta: MetaData(timestamp: DateTime.now().toIso8601String()),
          error: ErrorData(
            code: response.statusCode ?? 0,
            details: errorMessage,
          ),
        );
      }

      throw DioException(
        requestOptions: RequestOptions(path: url),
        error: 'Invalid response format',
        type: DioExceptionType.badResponse,
      );
    } on DioException catch (e) {
      if (kDebugMode) rethrow;

      // Create an error ApiResponse
      return ApiResponse<T>(
        success: false,
        message: DioErrorUtil.handleError(e),
        meta: MetaData(timestamp: DateTime.now().toIso8601String()),
        error: ErrorData(
          code: e.response?.statusCode ?? 0,
          details: e.response?.data?['message'] ?? DioErrorUtil.handleError(e),
        ),
      );
    } catch (e) {
      if (kDebugMode) rethrow;

      // Create an error ApiResponse for unexpected errors
      return ApiResponse<T>(
        success: false,
        message: e.toString(),
        meta: MetaData(timestamp: DateTime.now().toIso8601String()),
        error: ErrorData(code: 500, details: e.toString()),
      );
    }
  }

  /// Handy method to make http POST request with ApiResponse
  Future<ApiResponse<T>> postApiResponse<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    JsonConverter<T>? converter,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Configure Dio to not throw on error status codes
      final requestOptions = options ?? Options();
      requestOptions.validateStatus = (status) => true;

      final response = await dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      // For successful responses, parse as normal
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (converter != null) {
          return ApiResponseHandler.handleResponse<T>(response.data, converter);
        }
      }

      // For error responses, create an error ApiResponse
      if (response.data is Map<String, dynamic>) {
        // Try to extract error message from response
        final errorMessage =
            response.data['message'] as String? ??
            response.data['error']?['details'] as String? ??
            'Request failed with status: ${response.statusCode}';

        return ApiResponse<T>(
          success: false,
          message: errorMessage,
          meta: MetaData(timestamp: DateTime.now().toIso8601String()),
          error: ErrorData(
            code: response.statusCode ?? 0,
            details: errorMessage,
          ),
        );
      }

      throw DioException(
        requestOptions: RequestOptions(path: url),
        error: 'Invalid response format',
        type: DioExceptionType.badResponse,
      );
    } on DioException catch (e) {
      if (kDebugMode) rethrow;

      // Create an error ApiResponse
      return ApiResponse<T>(
        success: false,
        message: DioErrorUtil.handleError(e),
        meta: MetaData(timestamp: DateTime.now().toIso8601String()),
        error: ErrorData(
          code: e.response?.statusCode ?? 0,
          details: e.response?.data?['message'] ?? DioErrorUtil.handleError(e),
        ),
      );
    } catch (e) {
      if (kDebugMode) rethrow;

      // Create an error ApiResponse for unexpected errors
      return ApiResponse<T>(
        success: false,
        message: e.toString(),
        meta: MetaData(timestamp: DateTime.now().toIso8601String()),
        error: ErrorData(code: 500, details: e.toString()),
      );
    }
  }

  /// Handy method to make http GET request with ApiResponse that returns a List
  Future<ApiResponse<List<T>>> getApiListResponse<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? itemConverter,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Configure Dio to not throw on error status codes
      final requestOptions = options ?? Options();
      requestOptions.validateStatus = (status) => true;

      final response = await dio.get(
        url,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      // For successful responses, parse as normal
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data') &&
            itemConverter != null) {
          // Extract the data array from the response
          final dataList = responseData['data'];
          List<T> items = [];

          if (dataList is List) {
            // Convert each item in the list
            items =
                dataList
                    .map((item) => itemConverter(item as Map<String, dynamic>))
                    .toList();
          }

          // Create a successful ApiResponse
          return ApiResponse<List<T>>(
            success: responseData['success'] as bool? ?? true,
            message: responseData['message'] as String? ?? "Success",
            data: items,
            meta:
                responseData['meta'] != null
                    ? MetaData.fromJson(
                      responseData['meta'] as Map<String, dynamic>,
                    )
                    : MetaData(timestamp: DateTime.now().toIso8601String()),
          );
        }
      }

      // For error responses, create an error ApiResponse
      if (response.data is Map<String, dynamic>) {
        // Try to extract error message from response
        final errorMessage =
            response.data['message'] as String? ??
            response.data['error']?['details'] as String? ??
            'Request failed with status: ${response.statusCode}';

        return ApiResponse<List<T>>(
          success: false,
          message: errorMessage,
          meta: MetaData(timestamp: DateTime.now().toIso8601String()),
          error: ErrorData(
            code: response.statusCode ?? 0,
            details: errorMessage,
          ),
        );
      }

      throw DioException(
        requestOptions: RequestOptions(path: url),
        error: 'Invalid response format',
        type: DioExceptionType.badResponse,
      );
    } on DioException catch (e) {
      // Create an error ApiResponse
      return ApiResponse<List<T>>(
        success: false,
        message: DioErrorUtil.handleError(e),
        meta: MetaData(timestamp: DateTime.now().toIso8601String()),
        error: ErrorData(
          code: e.response?.statusCode ?? 0,
          details: e.response?.data?['message'] ?? DioErrorUtil.handleError(e),
        ),
      );
    } catch (e) {
      // Create an error ApiResponse for unexpected errors
      return ApiResponse<List<T>>(
        success: false,
        message: e.toString(),
        meta: MetaData(timestamp: DateTime.now().toIso8601String()),
        error: ErrorData(code: 500, details: e.toString()),
      );
    }
  }

  /// Handy method to make http GET request
  ///
  ///{@template dioClient}
  /// - [ReturnType] is the expected return type.
  /// - [DecoderType] is the return Type of decoder
  ///
  /// for example:
  /// 1. if [ReturnType] is User then [DecoderType] is User.
  ///
  /// 2. if [ReturnType] is List\<User\> then [DecoderType] is User.
  ///{@endtemplate}
  ///
  Future<Response<ReturnType?>> get<ReturnType, DecoderType>(
    String url, {
    Map<String, dynamic>? queryParameters,
    ResponseDecoderCallBack<DecoderType>? decoder,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) => _handelDecoding<ReturnType, DecoderType>(
    sendRequest:
        () => dio.get(
          url,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        ),
    decoder: decoder,
  );

  /// Handy method to make http POST request,
  ///
  /// {@macro dioClient}
  Future<Response<ReturnType?>> post<ReturnType, DecoderType>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    ResponseDecoderCallBack<DecoderType>? decoder,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _handelDecoding<ReturnType, DecoderType>(
    sendRequest:
        () => dio.post(
          url,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        ),
    decoder: decoder,
  );

  /// Handy method to make http PATCH request,
  ///
  /// {@macro dioClient}
  Future<Response<ReturnType?>> patch<ReturnType, DecoderType>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    ResponseDecoderCallBack<DecoderType>? decoder,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _handelDecoding<ReturnType, DecoderType>(
    sendRequest:
        () => dio.patch(
          url,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        ),
    decoder: decoder,
  );

  /// Handy method to make http PUT request,
  ///
  /// {@macro dioClient}
  Future<Response<ReturnType?>?> put<ReturnType, DecoderType>(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    ResponseDecoderCallBack<DecoderType>? decoder,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _handelDecoding<ReturnType, DecoderType>(
    sendRequest:
        () => dio.put(
          url,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        ),
    decoder: decoder,
  );

  /// Handy method to make http DELETE request,
  ///
  /// {@macro dioClient}
  Future<Response<ReturnType?>> delete<ReturnType, DecoderType>(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    ResponseDecoderCallBack<DecoderType>? decoder,
    Options? options,
    CancelToken? cancelToken,
  }) => _handelDecoding<ReturnType, DecoderType>(
    sendRequest:
        () => dio.delete(
          url,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ),
    decoder: decoder,
  );

  Future<Response<ReturnType?>> _handelDecoding<ReturnType, DecoderType>({
    required Future<Response> Function() sendRequest,
    ResponseDecoderCallBack<DecoderType>? decoder,
  }) async {
    try {
      final Response response = await sendRequest();
      ReturnType? result;

      if (decoder != null) {
        result = await _responseDecoder<ReturnType, DecoderType>(
          responseData: response.data,
          decoder: decoder,
        );
      } else if (response.data is ReturnType?) {
        result = response.data;
      }

      return response.copyWith<ReturnType>(data: result);
    } on DioException catch (e) {
      if (kDebugMode) rethrow;
      throw DioErrorUtil.handleError(e);
    } catch (e) {
      if (kDebugMode) rethrow;
      throw "Unexpected error occurred";
    }
  }

  Future<ReturnType?> _responseDecoder<ReturnType, DecoderType>({
    required dynamic responseData,
    required ResponseDecoderCallBack<DecoderType> decoder,
  }) async {
    if (responseData is List) {
      final result = await compute<dynamic, List<DecoderType>>(
        (message) => <DecoderType>[for (dynamic e in message) decoder(e)],
        responseData,
      );
      return result as ReturnType?;
    } else {
      return await compute<Map<String, dynamic>, DecoderType>(
            decoder,
            responseData,
          )
          as ReturnType?;
    }
  }
}

extension ResponseExtensions on Response {
  Response<T?> copyWith<T>({
    T? data,
    Headers? headers,
    RequestOptions? requestOptions,
    bool? isRedirect,
    int? statusCode,
    String? statusMessage,
    List<RedirectRecord>? redirects,
    Map<String, dynamic>? extra,
  }) => Response<T>(
    data: data ?? (this.data is T? ? this.data : null),
    headers: headers ?? this.headers,
    requestOptions: requestOptions ?? this.requestOptions,
    isRedirect: isRedirect ?? this.isRedirect,
    statusCode: statusCode ?? this.statusCode,
    statusMessage: statusMessage ?? this.statusMessage,
    redirects: redirects ?? this.redirects,
    extra: extra ?? this.extra,
  );
}
