import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/auth/providers/user_data_provider.dart';
import 'package:ugz_app/src/local/record/pending_forms_model.dart';
import 'package:ugz_app/src/local/usecases/stream_pending_forms/stream_pending_forms.dart';
import 'package:ugz_app/src/local/usecases/stream_pending_forms/stream_pending_forms_params.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

part 'history_pending_providers.g.dart';

@riverpod
class HistoryPending extends _$HistoryPending {
  @override
  FutureOr<Stream<List<PendingFormsModel>>> build() => getHistories();

  Stream<List<PendingFormsModel>> getHistories() async* {
    final streamPendingForms = ref.read(dbStreamPendingFormsProvider);

    final user = ref.watch(userDataProvider).valueOrNull;

    if (user == null) {
      yield [];
      return;
    }
    final result = await streamPendingForms(
      StreamPendingFormsParams(userId: user.id.toInt),
    );

    yield* result;
  }
}

@riverpod
class PendingFormsSelection extends _$PendingFormsSelection {
  @override
  Set<int> build() => {};

  void toggleSelection(int id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state}..add(id);
    }
  }

  void clearSelection() {
    state = {};
  }

  bool isSelected(int id) => state.contains(id);
}
