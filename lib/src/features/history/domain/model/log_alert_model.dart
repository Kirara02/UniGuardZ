import 'package:freezed_annotation/freezed_annotation.dart';

part 'log_alert_model.g.dart';
part 'log_alert_model.freezed.dart';

@freezed
abstract class LogAlertModel with _$LogAlertModel {
  const factory LogAlertModel({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'uuid') required String uuid,
    @JsonKey(name: 'log_id') required String logId,
    @JsonKey(name: 'log_uuid') required String logUuid,
    @JsonKey(name: 'reference_name') required String referenceName,
    @JsonKey(name: 'alert_event_name') required String alertEventName,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'original_submitted_time')
    required String originalSubmittedTime,
    @JsonKey(name: 'payload_data') required Map<String, dynamic> payloadData,
  }) = _LogAlertModel;

  factory LogAlertModel.fromJson(Map<String, dynamic> json) =>
      _$LogAlertModelFromJson(json);
}
