import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/local/interface/pending_forms_repository.dart';
import 'package:ugz_app/src/local/repository/pending_forms_repository_impl.dart';
import 'package:ugz_app/src/local/usecases/insert_pending_activity/insert_pending_activity_params.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'insert_pending_activity.g.dart';

class InsertPendingActivity
    implements UseCase<int, InsertPendingActivityParams> {
  final PendingFormsRepository _repository;

  InsertPendingActivity({required PendingFormsRepository repository})
    : _repository = repository;

  @override
  Future<int> call(InsertPendingActivityParams params) async {
    final result = await _repository.insertActivity(record: params.record);

    return result;
  }
}

@riverpod
InsertPendingActivity dbInsertPendingActivity(DbInsertPendingActivityRef ref) =>
    InsertPendingActivity(repository: ref.watch(pendingFormsRepositoryProvider));
