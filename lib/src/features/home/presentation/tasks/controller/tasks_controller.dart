import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/domain/model/task_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_tasks/get_task_usecase.dart';
import 'package:ugz_app/src/utils/misc/result.dart';

part 'tasks_controller.g.dart';

@riverpod
class TasksController extends _$TasksController {
  @override
  FutureOr<List<TaskModel>> build() => [];

  Future<void> getTasks() async {
    state = const AsyncLoading();

    GetTasks getTasks = ref.read(getTasksProvider);

    final result = await getTasks(null);

    if (!ref.exists(tasksControllerProvider)) return;

    switch (result) {
      case Success(value: final tasks):
        state = AsyncData(tasks);

      case Failed(message: _):
        state = const AsyncData([]);
    }
  }
}
