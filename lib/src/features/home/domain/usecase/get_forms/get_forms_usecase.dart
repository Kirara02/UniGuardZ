import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/forms_repository.dart';
import 'package:ugz_app/src/features/home/data/repository/forms_repository_impl.dart';
import 'package:ugz_app/src/features/home/domain/model/form_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_forms/get_forms_params.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'get_forms_usecase.g.dart';

class GetForms implements UseCase<Result<List<FormModel>>, GetFormsParams> {
  final FormsRepository _formsRepository;

  GetForms({required FormsRepository formsRepository})
    : _formsRepository = formsRepository;

  @override
  Future<Result<List<FormModel>>> call(GetFormsParams params) async {
    final response = await _formsRepository.getForms(
      limit: params.limit,
      page: params.page,
    );

    if (response.success && response.data != null) {
      return Result.success(response.data!, meta: response.meta);
    }

    return Result.failed(response.message);
  }
}

@riverpod
GetForms getForms(ref) =>
    GetForms(formsRepository: ref.watch(formsRepositoryProvider));
