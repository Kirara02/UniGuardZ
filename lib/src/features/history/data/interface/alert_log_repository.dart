import 'package:ugz_app/src/features/history/domain/model/log_alert_model.dart';
import 'package:ugz_app/src/utils/storage/dio/api_response.dart';

abstract interface class AlertLogRepository {
  Future<ApiResponse<List<LogAlertModel>>> getLogs({
    String? startDate,
    String? endDate,
    int? limit,
    int? page,
  });

  Future<ApiResponse<LogAlertModel>> getLogById({
    required String id
  });
}
