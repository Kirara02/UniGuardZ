
import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/auth/providers/user_data_provider.dart';
import 'package:ugz_app/src/local/record/pending_forms_model.dart';
import 'package:ugz_app/src/local/usecases/get_pending_forms/get_pending_forms.dart';
import 'package:ugz_app/src/local/usecases/get_pending_forms/get_pending_forms_params.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

part 'history_pending_providers.g.dart';

@riverpod
class HistoryPending extends _$HistoryPending {
  @override
  FutureOr<Stream<List<PendingFormsModel>>> build() => getHistories();

  Stream<List<PendingFormsModel>> getHistories() async* {
    final getPendingForms = ref.read(dbGetPendingFormsProvider);

    final userId = ref.watch(userDataProvider).valueOrNull;

    if (userId == null) {
      yield [];
      return;
    }
    final result = await getPendingForms(
      GetPendingFormsParams(userId: userId.id.toInt),
    );

    yield* result;
  }
}
