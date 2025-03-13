import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/local/interface/pending_forms_repository.dart';
import 'package:ugz_app/src/local/record/pending_forms_model.dart';
import 'package:ugz_app/src/local/repository/pending_forms_repository_impl.dart';
import 'package:ugz_app/src/local/usecases/get_pending_form_by_form_id/get_pending_form_by_form_id_params.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'get_pending_form_by_form_id_usecase.g.dart';

class GetPendingFormByFormId
    implements
        UseCase<Result<PendingFormsModel>, GetPendingFormByFormIdParams> {
  final PendingFormsRepository _repository;

  GetPendingFormByFormId({required PendingFormsRepository repository})
    : _repository = repository;

  @override
  Future<Result<PendingFormsModel>> call(
    GetPendingFormByFormIdParams params,
  ) async {
    final data = await _repository.getByFormId(params.formId);

    if (data != null) {
      return Result.success(data);
    }

    return Result.failed("Form with id '${params.formId}' not found");
  }
}

@riverpod
GetPendingFormByFormId dbGetPendingFormByFormId(
  DbGetPendingFormByFormIdRef ref,
) => GetPendingFormByFormId(
  repository: ref.watch(pendingFormsRepositoryProvider),
);
