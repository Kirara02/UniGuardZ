import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/forms_repository.dart';
import 'package:ugz_app/src/features/home/data/repository/forms_repository_impl.dart';
import 'package:ugz_app/src/features/home/domain/model/task_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_tasks/get_tasks_params.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'get_task_usecase.g.dart';

class GetTasks implements UseCase<Result<List<TaskModel>>, GetTasksParams> {
  final FormsRepository _formsRepository;

  GetTasks({required FormsRepository formsRepository})
    : _formsRepository = formsRepository;

  @override
  Future<Result<List<TaskModel>>> call(GetTasksParams params) async {
    final response = await _formsRepository.getTasks(
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
GetTasks getTasks(ref) =>
    GetTasks(formsRepository: ref.watch(formsRepositoryProvider));
