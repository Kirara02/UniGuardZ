import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/geolocation_repository.dart';
import 'package:ugz_app/src/features/home/domain/model/geolocation_model.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';
import 'package:ugz_app/src/utils/storage/dio/api_response.dart';
import 'package:ugz_app/src/utils/storage/dio/dio_client.dart';

part 'geolocation_repository_impl.g.dart';

class GeolocationRepositoryImpl implements GeolocationRepository {
  final DioClient _dioClient;

  GeolocationRepositoryImpl({required DioClient dioClient})
    : _dioClient = dioClient;
  @override
  Future<ApiResponse<GeolocationModel>> uploadLocation({
    required String token,
    required String buildCode,
    required String deviceName,
    required String deviceId,
    required double latitude,
    required double longitude,
  }) async {
    return await _dioClient.postApiResponse<GeolocationModel>(
      "mobile-api/admin/geolocation/log/interval",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
          "x-app-build": buildCode,
          'x-device-name': deviceName,
          'x-device-uid': deviceId,
        },
      ),
      data: {
        "latitude": latitude,
        "longitude": longitude,
        "original_submitted_time": DateTime.now().toUtc().toIso8601String(),
      },
      converter: (json) => GeolocationModel.fromJson(json),
    );
  }
}

@riverpod
GeolocationRepository geolocationRepository(ref) => GeolocationRepositoryImpl(
  dioClient: ref.watch(backgroundDioClientKeyProvider),
);
