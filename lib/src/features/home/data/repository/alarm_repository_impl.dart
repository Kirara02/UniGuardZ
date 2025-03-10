import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/alarm_repository.dart';
import 'package:ugz_app/src/features/home/domain/model/alarm_model.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';
import 'package:ugz_app/src/utils/storage/dio/api_response.dart';
import 'package:ugz_app/src/utils/storage/dio/dio_client.dart';

part 'alarm_repository_impl.g.dart';

class AlarmRepositoryImpl implements AlarmRepository {
  final DioClient _dioClient;

  AlarmRepositoryImpl({required DioClient dioClient}) : _dioClient = dioClient;

  @override
  Future<ApiResponse<AlarmModel>> startAlarm({
    required double latitude,
    required double longitude,
  }) async {
    return await _dioClient.postApiResponse<AlarmModel>(
      "mobile-api/admin/alarm/log/start",
      data: {
        "latitude": latitude,
        "longitude": longitude,
        "original_submitted_time": DateTime.now().toIso8601String(),
      },
      converter: (json) => AlarmModel.fromJson(json),
    );
  }

  @override
  Future<ApiResponse<AlarmModel>> stopAlarm(
    String id, {
    required double latitude,
    required double longitude,
  }) async {
    return await _dioClient.postApiResponse<AlarmModel>(
      "mobile-api/admin/alarm/log/stop/$id",
      data: {
        "latitude": latitude,
        "longitude": longitude,
        "original_submitted_time": DateTime.now().toIso8601String(),
      },
      converter: (json) => AlarmModel.fromJson(json),
    );
  }
}

@riverpod
AlarmRepository alarmRepository(AlarmRepositoryRef ref) =>
    AlarmRepositoryImpl(dioClient: ref.watch(dioClientKeyProvider));
