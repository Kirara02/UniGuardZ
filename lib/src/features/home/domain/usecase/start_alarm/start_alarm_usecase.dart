import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/alarm_repository.dart';
import 'package:ugz_app/src/features/home/data/repository/alarm_repository_impl.dart';
import 'package:ugz_app/src/features/home/domain/model/alarm_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/start_alarm/start_alarm_params.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'start_alarm_usecase.g.dart';

class StartAlarm implements UseCase<Result<AlarmModel>, StartAlarmParams> {
  final AlarmRepository _alarmRepository;

  StartAlarm({required AlarmRepository alarmRepository})
    : _alarmRepository = alarmRepository;

  @override
  Future<Result<AlarmModel>> call(StartAlarmParams params) async {
    final response = await _alarmRepository.startAlarm(
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
StartAlarm startAlarm(StartAlarmRef ref) =>
    StartAlarm(alarmRepository: ref.watch(alarmRepositoryProvider));