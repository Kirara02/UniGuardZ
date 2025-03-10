import 'package:dio/dio.dart';

import 'api_response.dart';

typedef JsonConverter<T> = T Function(Map<String, dynamic> json);

class ApiResponseHandler {
  /// Converts a raw JSON response to an ApiResponse with the specified data type
  static ApiResponse<T> handleResponse<T>(
    dynamic responseData,
    JsonConverter<T> converter,
  ) {
    if (responseData is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'Invalid response format',
        type: DioExceptionType.badResponse,
      );
    }

    final apiResponse = ApiResponse<T>.fromJson(
      responseData,
      (json) {
        if (json == null) return null as T;

        if (json is List) {
          // Handle list data
          return List<T>.from(
            json.map((item) => converter(item as Map<String, dynamic>)),
          ) as T;
        } else if (json is Map<String, dynamic>) {
          // Handle object data
          return converter(json);
        }

        // Return a default value that matches type T
        return null as T;
      },
    );

    return apiResponse;
  }
}
