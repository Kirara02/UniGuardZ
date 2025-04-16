import 'package:freezed_annotation/freezed_annotation.dart';

import '../../widgets/interface/base_field.dart';
import 'field_model.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
abstract class TaskModel with _$TaskModel {
  const factory TaskModel({
    @JsonKey(name: "id") required String id,
    @JsonKey(name: "task_type") required String taskType,
    @JsonKey(name: "task_name") required String taskName,
    @JsonKey(name: "task_description") required String taskDescription,
    @JsonKey(name: "start_time") required DateTime startTime,
    @JsonKey(name: "end_time") required DateTime endTime,
    @JsonKey(name: "allowed_time") required int allowedTime,
    @JsonKey(name: "active") required bool active,
    @JsonKey(name: "created_at") required DateTime createdAt,
    @JsonKey(name: "created_by") String? createdBy,
    @JsonKey(name: "updated_at") required DateTime updatedAt,
    @JsonKey(name: "updated_by") String? updatedBy,
    @JsonKey(name: "fields") required List<TaskFields> fields,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);
}

@freezed
abstract class TaskFields with _$TaskFields implements BaseField {
  const TaskFields._();

  const factory TaskFields({
    @JsonKey(name: "id") required String id,
    @JsonKey(name: "task_id") required String taskId,
    @JsonKey(name: "field_type_id") required String fieldTypeId,
    @JsonKey(name: "task_field_name") required String taskFieldName,
    @JsonKey(name: "task_field_description") String? taskFieldDescription,
    @JsonKey(name: "order") required int order,
    @JsonKey(name: "active") required bool active,
    @JsonKey(name: "created_at") required DateTime createdAt,
    @JsonKey(name: "created_by") String? createdBy,
    @JsonKey(name: "updated_at") required DateTime updatedAt,
    @JsonKey(name: "updated_by") String? updatedBy,
    @JsonKey(name: "field_type") required FieldType fieldType,
  }) = _TaskFields;

  factory TaskFields.fromJson(Map<String, dynamic> json) =>
      _$TaskFieldsFromJson(json);

  @override
  bool get IActive => active;

  @override
  String get IFieldName => taskFieldName;

  @override
  String get IFieldTypeId => fieldTypeId;

  @override
  String get Iid => id;

  @override
  bool get IRequired => true;

  @override
  PickList? get IPickList => null;
}
