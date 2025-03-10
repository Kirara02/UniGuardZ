import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/forms_repository.dart';
import 'package:ugz_app/src/features/home/data/repository/forms_repository_impl.dart';
import 'package:ugz_app/src/features/home/domain/model/form_model.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'get_forms_usecase.g.dart';

class GetForms implements UseCase<Result<List<FormModel>>, void> {
  final FormsRepository _formsRepository;

  GetForms({required FormsRepository formsRepository})
    : _formsRepository = formsRepository;

  @override
  Future<Result<List<FormModel>>> call(_) async {
    final response = await _formsRepository.getForms();

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failed(response.message);
  }
}

@riverpod
GetForms getForms(GetFormsRef ref) =>
    GetForms(formsRepository: ref.watch(formsRepositoryProvider));
