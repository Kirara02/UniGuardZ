import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/history/data/interface/alert_log_repository.dart';
import 'package:ugz_app/src/features/history/data/repository/alert_log_repository_impl.dart';
import 'package:ugz_app/src/features/history/domain/model/log_alert_model.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'get_log_by_id_usecase.g.dart';

class GetLogById implements UseCase<Result<LogAlertModel>, String> {
  final AlertLogRepository _alertLogRepository;

  GetLogById({required AlertLogRepository alertLogRepository})
    : _alertLogRepository = alertLogRepository;

  @override
  Future<Result<LogAlertModel>> call(String params) async {
    final response = await _alertLogRepository.getLogById(id: params);

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failed(response.message);
  }
}

@riverpod
GetLogById getLogById(ref) =>
    GetLogById(alertLogRepository: ref.watch(alertLogRepositoryProvider));
