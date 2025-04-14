import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/forms_repository.dart';
import 'package:ugz_app/src/features/home/data/repository/forms_repository_impl.dart';
import 'package:ugz_app/src/features/home/domain/model/task_model.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'get_task_by_id_usecase.g.dart';

class GetTaskById implements UseCase<Result<TaskModel>, String> {
  final FormsRepository _formsRepository;

  GetTaskById({required FormsRepository formsRepository})
    : _formsRepository = formsRepository;

  @override
  Future<Result<TaskModel>> call(String params) async {
    final response = await _formsRepository.getTaskById(id: params);

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }
    return Result.failed(response.message);
  }
}

@riverpod
GetTaskById getTaskById(ref) =>
    GetTaskById(formsRepository: ref.watch(formsRepositoryProvider));
