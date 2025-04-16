import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/history/domain/model/log_alert_model.dart';
import 'package:ugz_app/src/features/history/domain/usecase/get_logs/get_logs_params.dart';
import 'package:ugz_app/src/features/history/domain/usecase/get_logs/get_logs_usecase.dart';
import 'package:ugz_app/src/utils/misc/result.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  Future<LogAlertModel?> build() async {
    return _fetchLatestActivity();
  }

  Future<LogAlertModel?> _fetchLatestActivity() async {
    final getLogs = ref.read(getLogsProvider);
    final result = await getLogs(GetLogsParams(page: 1, limit: 1));

    switch (result) {
      case Success(value: final logs):
        return logs.isNotEmpty ? logs.first : null;
      case Failed(:final message):
        throw FlutterError(message);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final latestActivity = await _fetchLatestActivity();
      state = AsyncData(latestActivity);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
