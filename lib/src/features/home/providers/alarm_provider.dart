import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/constants/db_keys.dart';
import 'package:ugz_app/src/features/home/domain/model/alarm_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/start_alarm/start_alarm_params.dart';
import 'package:ugz_app/src/features/home/domain/usecase/start_alarm/start_alarm_usecase.dart';
import 'package:ugz_app/src/features/home/domain/usecase/stop_alarm/stop_alarm_params.dart';
import 'package:ugz_app/src/features/home/domain/usecase/stop_alarm/stop_alarm_usecase.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/mixin/shared_preferences_client_mixin.dart';

part 'alarm_provider.g.dart';

@Riverpod(keepAlive: true)
class Alarm extends _$Alarm {
  @override
  FutureOr<AlarmModel?> build() => null;

  Future<void> startAlarm({
    required StartAlarmParams params,
  }) async {
    state = const AsyncLoading();

    StartAlarm startAlarm = ref.read(startAlarmProvider);
    final result = await startAlarm(params);

    switch (result) {
      case Success(value: final alarm):
        state = AsyncData(alarm);

      case Failed(message: _):
        state = AsyncError(FlutterError, StackTrace.current);
        state = const AsyncData(null);
    }
  }

  Future<void> stopAlarm({
    required StopAlarmParams params,
  }) async {
    state = const AsyncLoading();

    StopAlarm stopAlarm = ref.read(stopAlarmProvider);
    final result = await stopAlarm(params);

    switch (result) {
      case Success(value: _):
        state = AsyncData(null);

      case Failed(:final message):
        state = AsyncError(FlutterError(message), StackTrace.current);
    }
  }
}

@riverpod
class AlarmIdKey extends _$AlarmIdKey with SharedPreferenceClientMixin<String> {
  @override
  String? build() => initialize(DBKeys.alarmId);
}