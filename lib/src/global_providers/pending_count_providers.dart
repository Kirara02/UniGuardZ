import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/auth/providers/user_data_provider.dart';
import 'package:ugz_app/src/local/usecases/get_count_pending_forms/get_count_pending_forms.dart';
import 'package:ugz_app/src/local/usecases/get_count_pending_forms/get_count_pending_forms_params.dart';

part 'pending_count_providers.g.dart';

@riverpod
Stream<int?> pendingCount(PendingCountRef ref) async* {
  final getFormsCount = ref.watch(dbGetCountPendingFormsProvider);

  final user = ref.watch(userDataProvider).valueOrNull;

  if (user?.id == null) {
    yield null;
    return;
  }

  final countStream = await getFormsCount(
    GetCountPendingFormsParams(userId: int.parse(user!.id)),
  );

  yield* countStream;
}
