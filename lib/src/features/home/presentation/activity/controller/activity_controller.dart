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

class ActivityState {
  final ActivityModel? activity;
  final bool isSubmitting;
  final bool isSubmitSuccess;
  final String? error;
  final bool isLoading;

  const ActivityState({
    this.activity,
    this.isSubmitting = false,
    this.isSubmitSuccess = false,
    this.error,
    this.isLoading = false,
  });

  ActivityState copyWith({
    ActivityModel? activity,
    bool? isSubmitting,
    bool? isSubmitSuccess,
    String? error,
    bool? isLoading,
  }) {
    return ActivityState(
      activity: activity ?? this.activity,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitSuccess: isSubmitSuccess ?? this.isSubmitSuccess,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class ActivityController extends _$ActivityController {
  @override
  ActivityState build(String? activityId) {
    if (activityId != null) {
      _fetchActivityDetail(activityId);
    }
    return const ActivityState(isLoading: true);
  }

  Future<void> _fetchActivityDetail(String activityId) async {
    try {
      final getActivityDetail = ref.read(getActivityByIdProvider);
      final result = await getActivityDetail(activityId);

      switch (result) {
        case Success(value: final activity):
          state = state.copyWith(activity: activity, isLoading: false);
        case Failed(message: final message):
          state = state.copyWith(error: message, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
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
    state = state.copyWith(isSubmitting: true, error: null);

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

      state = state.copyWith(isSubmitting: false, isSubmitSuccess: true);
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

      state = state.copyWith(isSubmitting: false, error: e.toString());
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

  void setSubmitting(bool isSubmitting) {
    state = state.copyWith(isSubmitting: isSubmitting);
  }
}
