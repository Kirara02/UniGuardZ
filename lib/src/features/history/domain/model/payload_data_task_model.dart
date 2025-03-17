import 'package:freezed_annotation/freezed_annotation.dart';

part 'payload_data_task_model.g.dart';
part 'payload_data_task_model.freezed.dart';

@freezed
abstract class PayloadDataTaskModel with _$PayloadDataTaskModel {
  const factory PayloadDataTaskModel({
    @JsonKey(name: "type") required String type,
    @JsonKey(name: "logTask") required LogTaskModel logTask,
    @JsonKey(name: "fields") required List<PayloadTaskFieldModel> fields,
  }) = _PayloadDataTaskModel;

  factory PayloadDataTaskModel.fromJson(Map<String, dynamic> json) =>
      _$PayloadDataTaskModelFromJson(json);
}

@freezed
abstract class LogTaskModel with _$LogTaskModel {
  const factory LogTaskModel({
    @JsonKey(name: "uuid") required String uuid,
    @JsonKey(name: "task_id") required int taskId,
    @JsonKey(name: "task_name") required String taskName,
    @JsonKey(name: "original_submitted_time")
    required String originalSubmittedTime,
    @JsonKey(name: "latitude") double? latitude,
    @JsonKey(name: "longitude") double? longitude,
  }) = _LogTaskModel;

  factory LogTaskModel.fromJson(Map<String, dynamic> json) =>
      _$LogTaskModelFromJson(json);
}

@freezed
abstract class PayloadTaskFieldModel with _$PayloadTaskFieldModel {
  const factory PayloadTaskFieldModel({
    @JsonKey(name: "id") required String id,
    @JsonKey(name: "log_task_id") required String logtaskId,
    @JsonKey(name: "field_type_id") required int fieldTypeId,
    @JsonKey(name: "field_type_name") required String fieldTypeName,
    @JsonKey(name: "task_field_name") required String taskFieldName,
    @JsonKey(name: "field_type_value") String? fieldTypeValue,
  }) = _PayloadTaskFieldModel;

  factory PayloadTaskFieldModel.fromJson(Map<String, dynamic> json) =>
      _$PayloadTaskFieldModelFromJson(json);
}
