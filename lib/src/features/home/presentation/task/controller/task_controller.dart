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

part 'task_controller.g.dart';

@riverpod
class TaskController extends _$TaskController {
  @override
  FutureOr<TaskModel?> build(String? taskId) {
    if (taskId != null) {
      _fetchTaskDetail(taskId);
    }
    return null;
  }

  Future<void> _fetchTaskDetail(String taskId) async {
    state = const AsyncLoading();
    try {
      final GetTaskById getTaskDetail = ref.read(getTaskByIdProvider);
      final result = await getTaskDetail(taskId);

      switch (result) {
        case Success(value: final activity):
          state = AsyncData(activity);
        case Failed(message: final message):
          state = AsyncError(Exception(message), StackTrace.current);
      }
    } catch (e, stack) {
      state = AsyncError(e, stack);
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
    state = const AsyncLoading();

    final List<TaskField> fields = [];
    final List<TaskPhoto> photos = [];

    // Handle comments (Text Input)
    fields.addAll(
      data.comments.map(
        (e) => TaskField(
          id: e.id.toString(),
          fieldTypeId: "2", // Text
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
          fieldTypeId: "3", // Checkbox
          fieldTypeName: "checkbox",
          taskFieldName: e.inputName!,
          value: (e.value == "true" || e.value == "1") ? "1" : "0",
        ),
      ),
    );

    // Handle photos
    photos.addAll(
      data.photos.map(
        (e) => TaskPhoto(id: e.id.toString(), filePath: e.value ?? ""),
      ),
    );

    // Tambahkan foto ke fields sebagai referensi
    fields.addAll(
      data.photos.map(
        (e) => TaskField(
          id: e.id.toString(),
          fieldTypeId: "4",
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
          fieldTypeId: "5",
          fieldTypeName: "signature",
          taskFieldName: "Signature ${e.id}",
          value: "signature_${e.id}",
        ),
      ),
    );

    // Handle selects (Dropdown, Radio, etc.)
    fields.addAll(
      data.selects.map(
        (e) => TaskField(
          id: e.id.toString(),
          fieldTypeId: "6",
          fieldTypeName: "options",
          taskFieldName: e.inputName!,
          value: e.value ?? "",
        ),
      ),
    );

    try {
      // Try submitting to API
      final success = await submitToApi(
        id: formId,
        latitude: latitude ?? 0.0,
        longitude: longitude ?? 0.0,
        timestamp: timestamp,
        fields: fields,
        photos: photos,
      );

      if (success) {
        // state = const AsyncData([]); // Success state
      } else {
        print('API submission failed, storing in local DB');
        // If API fails, store in local DB
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
      }
    } catch (e) {
      print('Error during submission: $e');
      // On error, store in local DB
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
    }
  }

  Future<void> insertTask({required InsertPendingTaskParams params}) async {
    // state = const AsyncLoading();
    final insert = ref.read(dbInsertPendingTaskProvider);
    await insert(params);

    // state = await AsyncValue.guard(() async {
    //   await insert(params);
    // });
  }

  Future<bool> submitToApi({
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
          return true;
        case Failed(message: _):
          return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }
}
