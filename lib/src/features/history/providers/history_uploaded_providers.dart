import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/history/domain/model/log_alert_model.dart';
import 'package:ugz_app/src/features/history/domain/usecase/get_logs/get_logs_params.dart';
import 'package:ugz_app/src/features/history/domain/usecase/get_logs/get_logs_usecase.dart';
import 'package:ugz_app/src/utils/misc/result.dart';

part 'history_uploaded_providers.g.dart';

class LogState {
  final List<LogAlertModel> logs;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  const LogState({
    this.logs = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = true,
  });

  LogState copyWith({
    List<LogAlertModel>? logs,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
  }) {
    return LogState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

@riverpod
class HistoryUploaded extends _$HistoryUploaded {
  @override
  LogState build() {
    return const LogState();
  }

  Future<void> getLogs() async {
    state = state.copyWith(isLoading: true, error: null);

    GetLogs getLogs = ref.read(getLogsProvider);
    final result = await getLogs(GetLogsParams(limit: 10, page: 1));

    switch (result) {
      case Success(value: final logs, meta: final meta):
        state = state.copyWith(
          logs: logs,
          isLoading: false,
          currentPage: 1,
          totalPages: meta?.total_pages ?? 1,
          hasMore:
              meta?.page != null &&
              meta?.total_pages != null &&
              meta!.page! < meta.total_pages!,
        );

      case Failed(message: final message):
        state = state.copyWith(isLoading: false, error: message);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    GetLogs getLogs = ref.read(getLogsProvider);
    final result = await getLogs(
      GetLogsParams(limit: 10, page: state.currentPage + 1),
    );

    switch (result) {
      case Success(value: final logs, meta: final meta):
        state = state.copyWith(
          logs: [...state.logs, ...logs],
          isLoadingMore: false,
          currentPage: state.currentPage + 1,
          totalPages: meta?.total_pages ?? state.totalPages,
          hasMore:
              meta?.page != null &&
              meta?.total_pages != null &&
              meta!.page! < meta.total_pages!,
        );

      case Failed(message: final message):
        state = state.copyWith(isLoadingMore: false, error: message);
    }
  }
}

// @riverpod
// class HistoryUploaded extends _$HistoryUploaded {
//   static const _pageSize = 10;
//   int _currentPage = 1;
//   bool _hasMore = true;
//
//   bool get hasMore => _hasMore;
//
//   @override
//   Future<List<LogAlertModel>> build() async {
//     return _fetchLogs(GetLogsParams(page: 1, limit: _pageSize));
//   }
//
//   Future<List<LogAlertModel>> _fetchLogs(GetLogsParams params) async {
//     final getLogs = ref.read(getLogsProvider);
//     final result = await getLogs(params);
//
//     switch (result) {
//       case Success(value: final logs):
//         _hasMore = logs.length >= _pageSize;
//         _currentPage = params.page ?? 1;
//         return logs;
//       case Failed(:final message):
//         throw FlutterError(message);
//     }
//   }
//
//   Future<void> loadMore() async {
//     if (!_hasMore) return;
//
//     final nextPage = _currentPage + 1;
//     final newLogs = await _fetchLogs(
//       GetLogsParams(page: nextPage, limit: _pageSize),
//     );
//
//     state.whenData((currentLogs) {
//       state = AsyncData([...currentLogs, ...newLogs]);
//     });
//   }
//
//   Future<void> refresh() async {
//     _currentPage = 1;
//     _hasMore = true;
//     state = const AsyncLoading();
//     try {
//       final logs = await _fetchLogs(GetLogsParams(page: 1, limit: _pageSize));
//       state = AsyncData(logs);
//     } catch (e) {
//       state = AsyncError(e, StackTrace.current);
//     }
//   }
// }
