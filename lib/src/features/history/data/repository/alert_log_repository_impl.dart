import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/history/data/interface/alert_log_repository.dart';
import 'package:ugz_app/src/features/history/domain/model/log_alert_model.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';
import 'package:ugz_app/src/utils/storage/dio/api_response.dart';
import 'package:ugz_app/src/utils/storage/dio/dio_client.dart';

part 'alert_log_repository_impl.g.dart';

class AlertLogRepositoryImpl implements AlertLogRepository {
  final DioClient _dioClient;

  AlertLogRepositoryImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<ApiResponse<LogAlertModel>> getLogById({required String id}) async {
    return await _dioClient.getApiResponse<LogAlertModel>(
      'mobile-api/admin/log-alert/$id',
      converter: (json) {
        return LogAlertModel.fromJson(json);
      },
    );
  }

  @override
  Future<ApiResponse<List<LogAlertModel>>> getLogs({
    String? startDate,
    String? endDate,
    int? limit,
    int? page,
  }) async {
    final queryParameters = <String, dynamic>{
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    };

    return await _dioClient.getApiListResponse<LogAlertModel>(
      'mobile-api/admin/log-alert',
      queryParameters: queryParameters,
      itemConverter: (json) {
        return LogAlertModel.fromJson(json);
      },
    );
  }
}

@riverpod
AlertLogRepository alertLogRepository(AlertLogRepositoryRef ref) =>
    AlertLogRepositoryImpl(dioClient: ref.watch(dioClientKeyProvider));
