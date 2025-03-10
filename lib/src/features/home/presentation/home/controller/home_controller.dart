import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/domain/model/activity_model.dart';
import 'package:ugz_app/src/features/home/domain/model/form_model.dart';
import 'package:ugz_app/src/features/home/domain/model/task_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_activities/get_activities.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_forms/get_forms_usecase.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_tasks/get_task_usecase.dart';
import 'package:ugz_app/src/utils/misc/result.dart';

part 'home_controller.g.dart';

final pageProvider = StateProvider<int>((ref) => 0);

@riverpod
class Forms extends _$Forms {
  @override
  FutureOr<List<FormModel>> build() => [];

  Future<void> getForms() async {
    state = const AsyncLoading();

    GetForms getForms = ref.read(getFormsProvider);
    final result = await getForms(null);

    if (!ref.exists(formsProvider)) return;

    switch (result) {
      case Success(value: final forms):
        state = AsyncData(forms);

      case Failed(message: _):
        state = const AsyncData([]);
    }
  }
}

@riverpod
class Activities extends _$Activities {
  @override
  FutureOr<List<ActivityModel>> build() => [];

  Future<void> getActivities() async {
    state = const AsyncLoading();

    GetActivities getActivities = ref.read(getActivitiesProvider);
    final result = await getActivities(null);

    if (!ref.exists(activitiesProvider)) return;

    switch (result) {
      case Success(value: final activities):
        state = AsyncData(activities);

      case Failed(message: _):
        state = const AsyncData([]);
    }
  }
}

@riverpod
class Tasks extends _$Tasks {
  @override
  FutureOr<List<TaskModel>> build() => [];

  Future<void> getTasks() async {
    state = const AsyncLoading();

    GetTasks getTasks = ref.read(getTasksProvider);

    final result = await getTasks(null);

    if (!ref.exists(tasksProvider)) return;

    switch (result) {
      case Success(value: final tasks):
        state = AsyncData(tasks);

      case Failed(message: _):
        state = const AsyncData([]);
    }
  }
}
