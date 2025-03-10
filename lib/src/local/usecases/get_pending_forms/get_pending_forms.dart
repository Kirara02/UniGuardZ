import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/local/interface/pending_forms_repository.dart';
import 'package:ugz_app/src/local/record/pending_forms_model.dart';
import 'package:ugz_app/src/local/repository/pending_forms_repository_impl.dart';
import 'package:ugz_app/src/local/usecases/get_pending_forms/get_pending_forms_params.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'get_pending_forms.g.dart';

class GetPendingForms
    implements UseCase<Stream<List<PendingFormsModel>>, GetPendingFormsParams> {
  final PendingFormsRepository _repository;

  GetPendingForms({required PendingFormsRepository repository})
    : _repository = repository;

  @override
  Future<Stream<List<PendingFormsModel>>> call(
    GetPendingFormsParams params,
  ) async {
    final result = _repository.getUsersHistories(
      partitionKey: "user:${params.userId}",
    );

    return result;
  }
}

@riverpod
GetPendingForms dbGetPendingForms(DbGetPendingFormsRef ref) =>
    GetPendingForms(repository: ref.watch(pendingFormsRepositoryProvider));

