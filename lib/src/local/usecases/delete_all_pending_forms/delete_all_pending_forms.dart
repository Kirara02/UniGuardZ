import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/local/interface/pending_forms_repository.dart';
import 'package:ugz_app/src/local/repository/pending_forms_repository_impl.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'delete_all_pending_forms.g.dart';

class DeleteAllPendingForms implements UseCase<int, void> {
  final PendingFormsRepository _repository;

  DeleteAllPendingForms({required PendingFormsRepository repository})
    : _repository = repository;
  @override
  Future<int> call(void params) async {
    return _repository.deleteAll();
  }
}

@riverpod
DeleteAllPendingForms dbDeleteAllPendingForms(DbDeleteAllPendingFormsRef ref) =>
    DeleteAllPendingForms(
      repository: ref.watch(pendingFormsRepositoryProvider),
    );
