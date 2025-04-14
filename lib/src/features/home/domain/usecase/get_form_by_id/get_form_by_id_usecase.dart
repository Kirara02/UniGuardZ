import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/forms_repository.dart';
import 'package:ugz_app/src/features/home/data/repository/forms_repository_impl.dart';
import 'package:ugz_app/src/features/home/domain/model/form_model.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'get_form_by_id_usecase.g.dart';

class GetFormById implements UseCase<Result<FormModel>, String> {
  final FormsRepository _formsRepository;

  GetFormById({required FormsRepository formsRepository})
    : _formsRepository = formsRepository;

  @override
  Future<Result<FormModel>> call(String params) async {
    final response = await _formsRepository.getFormById(id: params);

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }
    return Result.failed(response.message);
  }
}

@riverpod
GetFormById getFormById(ref) =>
    GetFormById(formsRepository: ref.watch(formsRepositoryProvider));
