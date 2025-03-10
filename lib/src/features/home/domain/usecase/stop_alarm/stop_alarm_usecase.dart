import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/alarm_repository.dart';
import 'package:ugz_app/src/features/home/data/repository/alarm_repository_impl.dart';
import 'package:ugz_app/src/features/home/domain/model/alarm_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/stop_alarm/stop_alarm_params.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'stop_alarm_usecase.g.dart';

class StopAlarm implements UseCase<Result<AlarmModel>, StopAlarmParams> {
  final AlarmRepository _alarmRepository;

  StopAlarm({required AlarmRepository alarmRepository})
    : _alarmRepository = alarmRepository;

  @override
  Future<Result<AlarmModel>> call(StopAlarmParams params) async {
    final response = await _alarmRepository.stopAlarm(
      params.id,
      latitude: params.latitude,
      longitude: params.longitude,
    );

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    } else {
      return Result.failed(response.message);
    }
  }
}

@riverpod
StopAlarm stopAlarm(StopAlarmRef ref) =>
    StopAlarm(alarmRepository: ref.watch(alarmRepositoryProvider));
