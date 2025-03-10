import 'package:ugz_app/src/features/home/domain/model/alarm_model.dart';
import 'package:ugz_app/src/utils/storage/dio/api_response.dart';

abstract interface class AlarmRepository {
  Future<ApiResponse<AlarmModel>> startAlarm({
    required double latitude,
    required double longitude,
  });
  Future<ApiResponse<AlarmModel>> stopAlarm(
    String id, {
    required double latitude,
    required double longitude,
  });
}
