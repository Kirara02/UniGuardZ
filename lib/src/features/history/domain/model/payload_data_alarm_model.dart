import 'package:freezed_annotation/freezed_annotation.dart';

part 'payload_data_alarm_model.g.dart';
part 'payload_data_alarm_model.freezed.dart';

@freezed
abstract class PayloadDataAlarmModel with _$PayloadDataAlarmModel {
  const factory PayloadDataAlarmModel({
    @JsonKey(name: "type") required String type,
    @JsonKey(name: "alarm") required LogAlarmModel alarm,
  }) = _PayloadDataAlarmModel;

  factory PayloadDataAlarmModel.fromJson(Map<String, dynamic> json) =>
      _$PayloadDataAlarmModelFromJson(json);
}

@freezed
abstract class LogAlarmModel with _$LogAlarmModel {
  const factory LogAlarmModel({
    @JsonKey(name: "uuid") required String uuid,
    @JsonKey(name: "device_name") String? deviceName,
    @JsonKey(name: "start_latitude") double? startLatitude,
    @JsonKey(name: "start_longitude") double? startLongitude,
    @JsonKey(name: "end_latitude") double? endLatitude,
    @JsonKey(name: "end_longitude") double? endLongitude,
    @JsonKey(name: "start_date_time") String? startDateTime,
    @JsonKey(name: "end_date_time") String? endDateTime,
    @JsonKey(name: "original_submitted_time")
    required String originalSubmittedTime,
  }) = _LogAlarmModel;

  factory LogAlarmModel.fromJson(Map<String, dynamic> json) =>
      _$LogAlarmModelFromJson(json);
}
