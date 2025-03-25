import 'package:freezed_annotation/freezed_annotation.dart';

part 'scan_nfc_submit_model.g.dart';
part 'scan_nfc_submit_model.freezed.dart';

@freezed
abstract class ScanNfcSubmitModel with _$ScanNfcSubmitModel {
  const factory ScanNfcSubmitModel({
    @JsonKey(name: "uuid") required String uuid,
    @JsonKey(name: "parent_branch_id") required String parentBranchId,
    @JsonKey(name: "branch_id") required String branchId,
    @JsonKey(name: "branch_name") required String branchName,
    @JsonKey(name: "role_id") required String roleId,
    @JsonKey(name: "role_name") required String roleName,
    @JsonKey(name: "user_id") required String userId,
    @JsonKey(name: "user_name") required String userName,
    @JsonKey(name: "timezone_id") required String timezoneId,
    @JsonKey(name: "timezone_name") required String timezoneName,
    @JsonKey(name: "latitude") required double latitude,
    @JsonKey(name: "longitude") required double longitude,
    @JsonKey(name: "checkpoint_id") required String checkpointId,
    @JsonKey(name: "checkpoint_name") required String checkpointName,
    @JsonKey(name: "zone_id") required String zoneId,
    @JsonKey(name: "zone_name") required String zoneName,
    @JsonKey(name: "is_beacon") required bool isBeacon,
    @JsonKey(name: "major_value") required int majorValue,
    @JsonKey(name: "minor_value") required int minorValue,
    @JsonKey(name: "checkpoint_type_id") required String checkpointTypeId,
    @JsonKey(name: "serial_number") required String serialNumber,
    @JsonKey(name: "device_id") required int deviceId,
    @JsonKey(name: "device_name") required String deviceName,
    @JsonKey(name: "original_submitted_time")
    required DateTime originalSubmittedTime,
    @JsonKey(name: "event_time") required DateTime eventTime,
    @JsonKey(name: "is_required_day") double? isRequiredDay,
    @JsonKey(name: "target_scan_count") int? targetScanCount,
    @JsonKey(name: "id") required String id,
  }) = _ScanNfcSubmitModel;

  factory ScanNfcSubmitModel.fromJson(Map<String, dynamic> json) =>
      _$ScanNfcSubmitModelFromJson(json);
}
