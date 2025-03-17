import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/constants/enum.dart';
import 'package:ugz_app/src/features/history/domain/usecase/get_log_by_id/get_log_by_id_usecase.dart';
import 'package:ugz_app/src/local/usecases/get_pending_form_by_form_id/get_pending_form_by_form_id_params.dart';
import 'package:ugz_app/src/local/usecases/get_pending_form_by_form_id/get_pending_form_by_form_id_usecase.dart';
import 'package:ugz_app/src/utils/misc/result.dart';

part 'history_detail_controller.g.dart';

class HistoryDetailState {
  final bool isLoading;
  final Map<String, dynamic>? data;
  final String? error;

  HistoryDetailState({this.isLoading = false, this.data, this.error});

  HistoryDetailState copyWith({
    bool? isLoading,
    Map<String, dynamic>? data,
    String? error,
  }) {
    return HistoryDetailState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}

@riverpod
class HistoryDetailController extends _$HistoryDetailController {
  @override
  HistoryDetailState build(String historyId, HistoryType historyType) {
    // Start loading immediately
    _loadData(historyId, historyType);
    // Return initial loading state
    return HistoryDetailState(isLoading: true);
  }

  Future<void> _loadData(String historyId, HistoryType historyType) async {
    try {
      if (historyType == HistoryType.pending) {
        await getHistoryFromDb(historyId);
      } else {
        await getHistoryFromApi(historyId);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> getHistoryFromDb(String historyId) async {
    try {
      final getByFormId = ref.read(dbGetPendingFormByFormIdProvider);

      final result = await getByFormId(
        GetPendingFormByFormIdParams(formId: historyId),
      );

      switch (result) {
        case Success(value: final form):
          state = state.copyWith(isLoading: false, data: form.toJson());

        case Failed(:final message):
          state = state.copyWith(isLoading: false, error: message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> getHistoryFromApi(String historyId) async {
    try {
      final getLog = ref.read(getLogByIdProvider);
      final result = await getLog(historyId);

      switch (result) {
        case Success(value: final log):
          state = state.copyWith(isLoading: false, data: log.toJson());
        case Failed(:final message):
          state = state.copyWith(isLoading: false, error: message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
