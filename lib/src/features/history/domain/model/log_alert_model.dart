import 'package:freezed_annotation/freezed_annotation.dart';

part 'log_alert_model.g.dart';
part 'log_alert_model.freezed.dart';

@freezed
abstract class LogAlertModel with _$LogAlertModel {
  const factory LogAlertModel({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'uuid') required String uuid,
    @JsonKey(name: 'alert_event_id') required String alertEventId,
    @JsonKey(name: 'alert_event_name') required String alertEventName,
    @JsonKey(name: 'log_id') required String logId,
    @JsonKey(name: 'log_uuid') required String logUuid,
    @JsonKey(name: 'reference_name') required String referenceName,
    @JsonKey(name: 'branch_id')  String? branchId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'role_id') required String roleId,
    @JsonKey(name: 'original_submitted_time')
    required String originalSubmittedTime,
    @JsonKey(name: 'event_time') required String eventTime,
    @JsonKey(name: 'payload_data') required Map<String, dynamic> payloadData,
  }) = _LogAlertModel;

  factory LogAlertModel.fromJson(Map<String, dynamic> json) =>
      _$LogAlertModelFromJson(json);
}
