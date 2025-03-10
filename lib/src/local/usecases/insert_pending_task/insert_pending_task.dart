import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/local/interface/pending_forms_repository.dart';
import 'package:ugz_app/src/local/repository/pending_forms_repository_impl.dart';
import 'package:ugz_app/src/local/usecases/insert_pending_task/insert_pending_task_params.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'insert_pending_task.g.dart';

class InsertPendingTask implements UseCase<int, InsertPendingTaskParams> {
  final PendingFormsRepository _repository;

  InsertPendingTask({required PendingFormsRepository repository})
    : _repository = repository;

  @override
  Future<int> call(InsertPendingTaskParams params) async {
    final result = await _repository.insertTask(record: params.record);

    return result;
  }
}

@riverpod
InsertPendingTask dbInsertPendingTask(DbInsertPendingTaskRef ref) =>
    InsertPendingTask(repository: ref.watch(pendingFormsRepositoryProvider));
