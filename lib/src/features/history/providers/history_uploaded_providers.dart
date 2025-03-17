import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/history/domain/model/log_alert_model.dart';
import 'package:ugz_app/src/features/history/domain/usecase/get_logs/get_logs_params.dart';
import 'package:ugz_app/src/features/history/domain/usecase/get_logs/get_logs_usecase.dart';
import 'package:ugz_app/src/utils/misc/result.dart';

part 'history_uploaded_providers.g.dart';

@riverpod
class HistoryUploaded extends _$HistoryUploaded {
  @override
  Future<List<LogAlertModel>> build() async {
    return _fetchLogs(GetLogsParams());
  }

  Future<List<LogAlertModel>> _fetchLogs(GetLogsParams params) async {
    final getLogs = ref.read(getLogsProvider);
    final result = await getLogs(params);

    switch (result) {
      case Success(value: final logs):
        return logs;
      case Failed(:final message):
        throw FlutterError(message);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final logs = await _fetchLogs(GetLogsParams());
      state = AsyncData(logs);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
