import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/domain/model/activity_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_activity_by_id/get_activity_by_id_usecase.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_activity/submit_activity_params.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_activity/submit_activity_usecase.dart';
import 'package:ugz_app/src/local/record/activity_log_submit_record.dart';
import 'package:ugz_app/src/local/record/form_data.dart';
import 'package:ugz_app/src/local/usecases/insert_pending_activity/insert_pending_activity.dart';
import 'package:ugz_app/src/local/usecases/insert_pending_activity/insert_pending_activity_params.dart';
import 'package:ugz_app/src/utils/misc/result.dart';

part 'activity_controller.g.dart';

@riverpod
class ActivityController extends _$ActivityController {
  @override
  FutureOr<ActivityModel?> build(String? activityId) {
    if (activityId != null) {
      _fetchActivityDetail(activityId);
    }
    return null;
  }

  Future<void> _fetchActivityDetail(String activityId) async {
    state = const AsyncLoading();
    try {
      final getActivityDetail = ref.read(getActivityByIdProvider);
      final result = await getActivityDetail(activityId);

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
    // Store the current activity data before setting loading state
    final currentActivity = state.valueOrNull;

    state = const AsyncLoading();
    try {
      final String? comment =
          data.comments.isNotEmpty ? data.comments.first.value : null;
      final String? photoPath =
          data.photos.isNotEmpty ? data.photos.first.value : null;

      final success = await _submitToApi(
        id: formId,
        latitude: latitude ?? 0.0,
        longitude: longitude ?? 0.0,
        timestamp: timestamp,
        comment: comment,
        photoPath: photoPath,
      );

      if (!success) {
        await _insertToLocalDb(
          params: InsertPendingActivityParams(
            record: ActivityLogSubmitRecord(
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

      // After submission, restore the activity data with a success flag
      if (currentActivity != null) {
        state = AsyncData(currentActivity);
      } else {
        // If we don't have the activity data, fetch it again
        await _fetchActivityDetail(formId);
      }
    } catch (e) {
      await _insertToLocalDb(
        params: InsertPendingActivityParams(
          record: ActivityLogSubmitRecord(
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

      // After handling the error, restore the activity data
      if (currentActivity != null) {
        state = AsyncData(currentActivity);
      } else {
        state = AsyncError(e, StackTrace.current);
      }
    }
  }

  Future<bool> _submitToApi({
    required String id,
    required double latitude,
    required double longitude,
    required String timestamp,
    String? comment,
    String? photoPath,
  }) async {
    final submitActivityUseCase = ref.read(submitActivityProvider);
    try {
      final result = await submitActivityUseCase(
        SubmitActivityParams(
          id: id,
          latitude: latitude,
          longitude: longitude,
          comment: comment,
          photo: photoPath != null ? File(photoPath) : null,
          timestamp: DateTime.now(),
        ),
      );
      switch (result) {
        case Success(value: _):
          return true;
        case Failed(message: _):
          return false;
      }
    } catch (_) {
      return false;
    }
  }

  Future<void> _insertToLocalDb({
    required InsertPendingActivityParams params,
  }) async {
    final insert = ref.read(dbInsertPendingActivityProvider);
    await insert(params);
  }
}
