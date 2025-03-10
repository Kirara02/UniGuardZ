import 'package:freezed_annotation/freezed_annotation.dart';

part 'alarm_model.freezed.dart';
part 'alarm_model.g.dart';

@freezed
abstract class AlarmModel with _$AlarmModel {

  const factory AlarmModel({
    @JsonKey(name: "uuid") required String uuid,
    @JsonKey(name: "parent_branch_id") required String parentBranchId,
    @JsonKey(name: "branch_id") required String branchId,
    @JsonKey(name: "branch_name") required String branchName,
    @JsonKey(name: "role_id") String? roleId,
    @JsonKey(name: "role_name") required String roleName,
    @JsonKey(name: "user_id") required String userId,
    @JsonKey(name: "user_name") required String userName,
    @JsonKey(name: "timezone_id") required String timezoneId,
    @JsonKey(name: "timezone_name") required String timezoneName,
    @JsonKey(name: "start_date_time") required DateTime startDateTime,
    @JsonKey(name: "start_latitude") required double startLatitude,
    @JsonKey(name: "start_longitude") required double startLongitude,
    @JsonKey(name: "original_submitted_time") required DateTime originalSubmittedTime,
    @JsonKey(name: "event_time") required DateTime eventTime,
    @JsonKey(name: "device_id") String? deviceId,
    @JsonKey(name: "device_name") String? deviceName,
    @JsonKey(name: "end_date_time") DateTime? endDateTime,
    @JsonKey(name: "end_latitude") double? endLatitude,
    @JsonKey(name: "end_longitude") double? endLongitude,
    @JsonKey(name: "id") required String id,
}) = _AlarmModel;


  factory AlarmModel.fromJson(Map<String, dynamic> json) =>
      _$AlarmModelFromJson(json);
}