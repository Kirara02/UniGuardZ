import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_submit_model.g.dart';
part 'activity_submit_model.freezed.dart';

@freezed
abstract class ActivitySubmitModel with _$ActivitySubmitModel {
  const factory ActivitySubmitModel({
    @JsonKey(name: "uuid") required String uuid,
    @JsonKey(name: "form_id") required String formId,
    @JsonKey(name: "form_name") required String formName,
    @JsonKey(name: "parent_branch_id") required String parentBranchId,
    @JsonKey(name: "role_id") required String roleId,
    @JsonKey(name: "role_name") required String roleName,
    @JsonKey(name: "user_id") required String userId,
    @JsonKey(name: "user_name") required String userName,
    @JsonKey(name: "latitude") required double latitude,
    @JsonKey(name: "longitude") required double longitude,
    @JsonKey(name: "timezone_id") required String timezoneId,
    @JsonKey(name: "timezone_name") required String timezoneName,
    @JsonKey(name: "original_submitted_time")
    required String originalSubmittedTime,
    @JsonKey(name: "event_time") required String eventTime,
    @JsonKey(name: "branch_id") String? branchId,
    @JsonKey(name: "branch_name") String? branchName,
    @JsonKey(name: "device_id") String? deviceId,
    @JsonKey(name: "device_name") String? deviceName,
    @JsonKey(name: "id") required String id,
  }) = _ActivitySubmitResponse;

  factory ActivitySubmitModel.fromJson(Map<String, dynamic> json) =>
      _$ActivitySubmitResponseFromJson(json);
}
