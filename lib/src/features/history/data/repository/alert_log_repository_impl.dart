import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/constants/endpoint.dart';
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
      LogUrl.withId(id),
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
    final now = DateTime.now();
    final oneMonthAgo = now.subtract(const Duration(days: 30));

    final queryParameters = <String, dynamic>{
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
      'start_date': startDate ?? oneMonthAgo.toIso8601String().split('T')[0],
      'end_date': endDate ?? now.toIso8601String().split('T')[0],
      // 'start_date': startDate ?? oneMonthAgo.toUtc().toIso8601String().split('T')[0],
      // 'end_date': endDate ?? now.toUtc().toIso8601String().split('T')[0],
    };

    return await _dioClient.getApiListResponse<LogAlertModel>(
      LogUrl.logs,
      queryParameters: queryParameters,
      itemConverter: (json) {
        return LogAlertModel.fromJson(json);
      },
    );
  }
}

@riverpod
AlertLogRepository alertLogRepository(ref) =>
    AlertLogRepositoryImpl(dioClient: ref.watch(dioClientKeyProvider));
