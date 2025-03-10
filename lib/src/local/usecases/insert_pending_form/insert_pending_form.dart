import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/local/interface/pending_forms_repository.dart';
import 'package:ugz_app/src/local/repository/pending_forms_repository_impl.dart';
import 'package:ugz_app/src/local/usecases/insert_pending_form/insert_pending_form_params.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'insert_pending_form.g.dart';

class InsertPendingForm implements UseCase<int, InsertPendingFormParams> {
  final PendingFormsRepository _repository;

  InsertPendingForm({required PendingFormsRepository repository})
    : _repository = repository;

  @override
  Future<int> call(InsertPendingFormParams params) async {
    final result = await _repository.insertForm(record: params.record);

    return result;
  }
}

@riverpod
InsertPendingForm dbInsertPendingForm(DbInsertPendingFormRef ref) =>
    InsertPendingForm(repository: ref.watch(pendingFormsRepositoryProvider));
