import 'package:freezed_annotation/freezed_annotation.dart';

part 'payload_data_checkpoint_model.g.dart';
part 'payload_data_checkpoint_model.freezed.dart';

@freezed
abstract class PayloadDataCheckpointModel with _$PayloadDataCheckpointModel {
  const factory PayloadDataCheckpointModel({
    @JsonKey(name: "type") required String type,
    @JsonKey(name: "logCheckpoint") required LogCheckpointModel logChekpoint,
  }) = _PayloadDataCheckpointModel;

  factory PayloadDataCheckpointModel.fromJson(Map<String, dynamic> json) =>
      _$PayloadDataCheckpointModelFromJson(json);
}

@freezed
abstract class LogCheckpointModel with _$LogCheckpointModel {
  const factory LogCheckpointModel({
    @JsonKey(name: "id") required String id,
    @JsonKey(name: "uuid") required String uuid,
    @JsonKey(name: "device_name") String? deviceName,
    @JsonKey(name: "checkpoint_name") String? checkpointName,
    @JsonKey(name: "serial_number") String? serialNumber,
    @JsonKey(name: "original_submitted_time")
    required String originalSubmittedTime,
    @JsonKey(name: "latitude") double? latitude,
    @JsonKey(name: "longitude") double? longitude,
  }) = _LogCheckpointModel;

  factory LogCheckpointModel.fromJson(Map<String, dynamic> json) =>
      _$LogCheckpointModelFromJson(json);
}
