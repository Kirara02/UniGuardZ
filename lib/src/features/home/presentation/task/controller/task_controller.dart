import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/domain/model/task_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_task_by_id/get_task_by_id_usecase.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_task/submit_task_params.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_task/submit_task_usecase.dart';
import 'package:ugz_app/src/local/record/form_data.dart';
import 'package:ugz_app/src/local/record/task_submit_record.dart';
import 'package:ugz_app/src/local/usecases/insert_pending_task/insert_pending_task.dart';
import 'package:ugz_app/src/local/usecases/insert_pending_task/insert_pending_task_params.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/network/connectivity.dart';

part 'task_controller.g.dart';

class TaskState {
  final TaskModel? task;
  final bool isSubmitting;
  final bool isSubmitSuccess;
  final String? error;
  final bool isLoading;

  const TaskState({
    this.task,
    this.isSubmitting = false,
    this.isSubmitSuccess = false,
    this.error,
    this.isLoading = false,
  });

  TaskState copyWith({
    TaskModel? task,
    bool? isSubmitting,
    bool? isSubmitSuccess,
    String? error,
    bool? isLoading,
  }) {
    return TaskState(
      task: task ?? this.task,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitSuccess: isSubmitSuccess ?? this.isSubmitSuccess,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class TaskController extends _$TaskController {
  @override
  TaskState build(String? taskId) {
    if (taskId != null) {
      _fetchTaskDetail(taskId);
    }
    return const TaskState(isLoading: true);
  }

  Future<void> _fetchTaskDetail(String taskId) async {
    try {
      final GetTaskById getTaskDetail = ref.read(getTaskByIdProvider);
      final result = await getTaskDetail(taskId);

      switch (result) {
        case Success(value: final task):
          state = state.copyWith(task: task, isLoading: false);
        case Failed(message: final message):
          state = state.copyWith(error: message, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<(bool, String?, int?)> submitToApi({
    required String id,
    required double latitude,
    required double longitude,
    required String timestamp,
    required List<TaskField> fields,
    required List<TaskPhoto> photos,
  }) async {
    final submitTaskUseCase = ref.read(submitTaskProvider);

    try {
      final result = await submitTaskUseCase(
        SubmitTaskParams(
          id: id,
          latitude: latitude,
          longitude: longitude,
          timestamp: timestamp,
          fields: fields,
          photos: photos,
        ),
      );

      switch (result) {
        case Success(value: _):
          return (true, null, null);
        case Failed(message: final message, code: final code):
          return (false, message, code);
      }
    } catch (e) {
      return (false, e.toString(), null);
    }
  }

  Future<void> submit({
    required String partitionKey,
    required String timestamp,
    required double? latitude,
    required double? longitude,
    required String description,
    required String formId,
    required FormData data,
  }) async {
    // Set submitting state
    state = state.copyWith(
      isSubmitting: true,
      isSubmitSuccess: false,
      error: null,
    );

    final List<TaskField> fields = [];
    final List<TaskPhoto> photos = [];

    // Handle comments (Text Input)
    fields.addAll(
      data.comments.map(
        (e) => TaskField(
          id: e.id.toString(),
          fieldTypeId: e.typeId!, // Text
          fieldTypeName: "text",
          taskFieldName: e.inputName!,
          value: e.value ?? "",
        ),
      ),
    );

    // Handle switches (Checkbox/Toggle)
    fields.addAll(
      data.switches.map(
        (e) => TaskField(
          id: e.id.toString(),
          fieldTypeId: e.typeId!, // Checkbox
          fieldTypeName: "checkbox",
          taskFieldName: e.inputName!,
          value: (e.value == "true" || e.value == "1") ? "true" : "false",
        ),
      ),
    );

    // Handle photos
    photos.addAll(
      data.photos.map(
        (e) => TaskPhoto(id: e.id.toString(), filePath: e.value ?? ""),
      ),
    );

    // Add photos to fields as references
    fields.addAll(
      data.photos.map(
        (e) => TaskField(
          id: e.id.toString(),
          fieldTypeId: e.typeId!,
          fieldTypeName: "image",
          taskFieldName: e.inputName!,
          value: "file_${e.id}",
        ),
      ),
    );

    // Handle signatures (treated like photos)
    photos.addAll(
      data.signatures.map(
        (e) => TaskPhoto(id: e.id.toString(), filePath: e.value ?? ""),
      ),
    );

    fields.addAll(
      data.signatures.map(
        (e) => TaskField(
          id: e.id.toString(),
          fieldTypeId: e.typeId!,
          fieldTypeName: "signature",
          taskFieldName: e.inputName!,
          value: "file_${e.id}",
        ),
      ),
    );

    // Handle selects (Dropdown, Radio, etc.)
    fields.addAll(
      data.selects.map(
        (e) => TaskField(
          id: e.id.toString(),
          fieldTypeId: e.typeId!,
          fieldTypeName: "options",
          taskFieldName: e.inputName!,
          value: e.value ?? "",
        ),
      ),
    );

    try {
      // Check internet connectivity
      final bool isConnected = await NetworkConnectivity.isConnected();

      if (isConnected) {
        // Try submitting to API
        final (success, error, errorCode) = await submitToApi(
          id: formId,
          latitude: latitude ?? 0.0,
          longitude: longitude ?? 0.0,
          timestamp: timestamp,
          fields: fields,
          photos: photos,
        );

        if (success) {
          state = state.copyWith(isSubmitting: false, isSubmitSuccess: true);
          return;
        } else {
          // Only store in local DB if it's a network error (5xx) or server error
          if (errorCode != null && errorCode >= 500) {
            await insertTask(
              params: InsertPendingTaskParams(
                record: TaskSubmitRecord(
                  formId: formId,
                  partitionKey: partitionKey,
                  timestamp: timestamp,
                  latitude: latitude,
                  longitude: longitude,
                  description: description,
                  data: data,
                ),
              ),
            );
            state = state.copyWith(
              isSubmitting: false,
              isSubmitSuccess: true,
              error:
                  error ??
                  "Failed to submit to server. Data saved locally and will be synced when connection is restored.",
            );
          } else {
            // For validation errors (400, 422, etc), show the error message without saving to local DB
            state = state.copyWith(isSubmitting: false, error: error);
          }
          return;
        }
      } else {
        // No internet connection, store in local DB
        await insertTask(
          params: InsertPendingTaskParams(
            record: TaskSubmitRecord(
              formId: formId,
              partitionKey: partitionKey,
              timestamp: timestamp,
              latitude: latitude,
              longitude: longitude,
              description: description,
              data: data,
            ),
          ),
        );
        state = state.copyWith(
          isSubmitting: false,
          isSubmitSuccess: true,
          error:
              "No internet connection. Data saved locally and will be synced when connection is restored.",
        );
        return;
      }
    } catch (e) {
      // On error, store in local DB
      try {
        await insertTask(
          params: InsertPendingTaskParams(
            record: TaskSubmitRecord(
              formId: formId,
              partitionKey: partitionKey,
              timestamp: timestamp,
              latitude: latitude,
              longitude: longitude,
              description: description,
              data: data,
            ),
          ),
        );
        state = state.copyWith(
          isSubmitting: false,
          isSubmitSuccess: true,
          error:
              "Error occurred. Data saved locally and will be synced when connection is restored.",
        );
      } catch (innerError) {
        state = state.copyWith(
          isSubmitting: false,
          error: "Failed to save data: $innerError",
        );
      }
    }
  }

  Future<void> insertTask({required InsertPendingTaskParams params}) async {
    final insert = ref.read(dbInsertPendingTaskProvider);
    await insert(params);
  }

  void setSubmitting(bool isSubmitting) {
    state = state.copyWith(isSubmitting: isSubmitting);
  }
}
