import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/history/data/interface/alert_log_repository.dart';
import 'package:ugz_app/src/features/history/data/repository/alert_log_repository_impl.dart';
import 'package:ugz_app/src/features/history/domain/model/log_alert_model.dart';
import 'package:ugz_app/src/features/history/domain/usecase/get_logs/get_logs_params.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'get_logs_usecase.g.dart';

class GetLogs implements UseCase<Result<List<LogAlertModel>>, GetLogsParams> {
  final AlertLogRepository _alertLogRepository;

  GetLogs({required AlertLogRepository alertLogRepository})
    : _alertLogRepository = alertLogRepository;

  @override
  Future<Result<List<LogAlertModel>>> call(GetLogsParams params) async {
    final response = await _alertLogRepository.getLogs(
      startDate: params.startDate,
      endDate: params.endDate,
      page: params.page,
      limit: params.limit,
    );

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failed(response.message);
  }
}

@riverpod
GetLogs getLogs(ref) =>
    GetLogs(alertLogRepository: ref.watch(alertLogRepositoryProvider));
