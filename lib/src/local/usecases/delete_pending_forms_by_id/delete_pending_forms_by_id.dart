import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/local/interface/pending_forms_repository.dart';
import 'package:ugz_app/src/local/repository/pending_forms_repository_impl.dart';
import 'package:ugz_app/src/local/usecases/delete_pending_forms_by_id/delete_pending_forms_by_id_params.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'delete_pending_forms_by_id.g.dart';

class DeletePendingFormsById
    implements UseCase<int, DeletePendingFormsByIdParams> {
  final PendingFormsRepository _repository;

  DeletePendingFormsById({required PendingFormsRepository repository})
    : _repository = repository;

  @override
  Future<int> call(DeletePendingFormsByIdParams params) async {
    final result = await _repository.deleteById(params.id);
    return result;
  }
}

@riverpod
DeletePendingFormsById dbDeletePendingFormsById(DbDeletePendingFormsByIdRef ref) =>
    DeletePendingFormsById(repository: ref.watch(pendingFormsRepositoryProvider));

