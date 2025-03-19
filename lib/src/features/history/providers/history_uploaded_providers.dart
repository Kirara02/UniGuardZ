import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/history/domain/model/log_alert_model.dart';
import 'package:ugz_app/src/features/history/domain/usecase/get_logs/get_logs_params.dart';
import 'package:ugz_app/src/features/history/domain/usecase/get_logs/get_logs_usecase.dart';
import 'package:ugz_app/src/utils/misc/result.dart';

part 'history_uploaded_providers.g.dart';

@Riverpod(keepAlive: true)
class HistoryUploaded extends _$HistoryUploaded {
  static const _pageSize = 10;
  int _currentPage = 1;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  Future<List<LogAlertModel>> build() async {
    return _fetchLogs(GetLogsParams(page: 1, limit: _pageSize));
  }

  Future<List<LogAlertModel>> _fetchLogs(GetLogsParams params) async {
    final getLogs = ref.read(getLogsProvider);
    final result = await getLogs(params);

    switch (result) {
      case Success(value: final logs):
        _hasMore = logs.length >= _pageSize;
        _currentPage = params.page ?? 1;
        return logs;
      case Failed(:final message):
        throw FlutterError(message);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;

    final nextPage = _currentPage + 1;
    final newLogs = await _fetchLogs(
      GetLogsParams(page: nextPage, limit: _pageSize),
    );

    state.whenData((currentLogs) {
      state = AsyncData([...currentLogs, ...newLogs]);
    });
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    state = const AsyncLoading();
    try {
      final logs = await _fetchLogs(GetLogsParams(page: 1, limit: _pageSize));
      state = AsyncData(logs);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
