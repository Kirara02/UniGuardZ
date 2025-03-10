import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_submit_model.freezed.dart';
part 'task_submit_model.g.dart';

@freezed
abstract class TaskSubmitModel with _$TaskSubmitModel {
  const factory TaskSubmitModel({
    @JsonKey(name: 'uuid') required String uuid,
    @JsonKey(name: 'parent_branch_id') required String parentBranchId,
    @JsonKey(name: 'branch_id') required String branchId,
    @JsonKey(name: 'branch_name') required String branchName,
    @JsonKey(name: 'task_id') required int taskId,
    @JsonKey(name: 'task_name') required String taskName,
    @JsonKey(name: 'task_type') required String taskType,
    @JsonKey(name: 'task_start_time') required String taskStartTime,
    @JsonKey(name: 'task_end_time') required String taskEndTime,
    @JsonKey(name: 'task_allowed_time') required int taskAllowedTime,
    @JsonKey(name: 'role_id') required String roleId,
    @JsonKey(name: 'role_name') required String roleName,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'user_name') required String userName,
    @JsonKey(name: 'timezone_id') required String timezoneId,
    @JsonKey(name: 'timezone_name') required String timezoneName,
    @JsonKey(name: 'latitude') required double latitude,
    @JsonKey(name: 'longitude') required double longitude,
    @JsonKey(name: 'original_submitted_time')
    required String originalSubmittedTime,
    @JsonKey(name: 'event_time') required String eventTime,
    @JsonKey(name: 'device_id') String? deviceId,
    @JsonKey(name: 'device_name') String? deviceName,
    @JsonKey(name: 'id') required String id,
  }) = _TaskSubmitModel;

  factory TaskSubmitModel.fromJson(Map<String, dynamic> json) =>
      _$TaskSubmitModelFromJson(json);
}
