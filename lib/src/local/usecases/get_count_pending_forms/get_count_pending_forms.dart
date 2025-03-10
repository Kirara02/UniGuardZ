import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/local/interface/pending_forms_repository.dart';
import 'package:ugz_app/src/local/repository/pending_forms_repository_impl.dart';
import 'package:ugz_app/src/local/usecases/get_count_pending_forms/get_count_pending_forms_params.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'get_count_pending_forms.g.dart';

class GetCountPendingForms
    implements UseCase<Stream<int>, GetCountPendingFormsParams> {
  final PendingFormsRepository _repository;

  GetCountPendingForms({required PendingFormsRepository repository})
    : _repository = repository;

  @override
  Future<Stream<int>> call(GetCountPendingFormsParams params) async {
    return _repository.count(partitionKey: "user:${params.userId}");
  }
}

@riverpod
GetCountPendingForms dbGetCountPendingForms(DbGetCountPendingFormsRef ref) =>
    GetCountPendingForms(repository: ref.watch(pendingFormsRepositoryProvider));
