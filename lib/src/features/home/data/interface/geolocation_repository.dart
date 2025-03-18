import 'package:ugz_app/src/features/home/domain/model/geolocation_model.dart';
import 'package:ugz_app/src/utils/storage/dio/api_response.dart';

abstract interface class GeolocationRepository {
  Future<ApiResponse<GeolocationModel>> uploadLocation({
    required String token,
    required String buildCode,
    required double latitude,
    required double longitude,
    required String deviceName,
    required String deviceId,
  });
}