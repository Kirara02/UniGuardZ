import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/domain/model/task_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_tasks/get_task_usecase.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_tasks/get_tasks_params.dart';
import 'package:ugz_app/src/utils/misc/result.dart';

part 'tasks_controller.g.dart';

class TasksState {
  final List<TaskModel> tasks;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  const TasksState({
    this.tasks = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = true,
  });

  TasksState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

@riverpod
class TasksController extends _$TasksController {
  @override
  TasksState build() {
    return const TasksState();
  }

  Future<void> getTasks() async {
    state = state.copyWith(isLoading: true, error: null);

    GetTasks getTasks = ref.read(getTasksProvider);
    final result = await getTasks(GetTasksParams(limit: 10, page: 1));

    if (!ref.exists(tasksControllerProvider)) return;

    switch (result) {
      case Success(value: final tasks, meta: final meta):
        state = state.copyWith(
          tasks: tasks,
          isLoading: false,
          currentPage: 1,
          totalPages: meta?.total_pages ?? 1,
          hasMore:
              meta?.page != null &&
              meta?.total_pages != null &&
              meta!.page! < meta.total_pages!,
        );

      case Failed(message: final message):
        state = state.copyWith(isLoading: false, error: message);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    GetTasks getTasks = ref.read(getTasksProvider);
    final result = await getTasks(
      GetTasksParams(limit: 10, page: state.currentPage + 1),
    );

    if (!ref.exists(tasksControllerProvider)) return;

    switch (result) {
      case Success(value: final tasks, meta: final meta):
        state = state.copyWith(
          tasks: [...state.tasks, ...tasks],
          isLoadingMore: false,
          currentPage: state.currentPage + 1,
          totalPages: meta?.total_pages ?? state.totalPages,
          hasMore:
              meta?.page != null &&
              meta?.total_pages != null &&
              meta!.page! < meta.total_pages!,
        );

      case Failed(message: final message):
        state = state.copyWith(isLoadingMore: false, error: message);
    }
  }
}
