import 'package:freezed_annotation/freezed_annotation.dart';

part 'field_model.freezed.dart';
part 'field_model.g.dart';

@freezed
abstract class FieldType with _$FieldType {
  const factory FieldType({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "field_type_name") required String fieldTypeName,
    @JsonKey(name: "field_type_description") String? fieldTypeDescription,
    @JsonKey(name: "active") required bool active,
    @JsonKey(name: "created_at") required DateTime createdAt,
    @JsonKey(name: "created_by") String? createdBy,
    @JsonKey(name: "updated_at") required DateTime updatedAt,
    @JsonKey(name: "updated_by") String? updatedBy,
  }) = _FieldType;

  factory FieldType.fromJson(Map<String, dynamic> json) =>
      _$FieldTypeFromJson(json);
}

@freezed
abstract class PickList with _$PickList {
  const factory PickList({
    @JsonKey(name: "id") required String id,
    @JsonKey(name: "branch_id") required String branchId,
    @JsonKey(name: "form_picklist_name") required String name,
    @JsonKey(name: "form_picklist_description") String? description,
    @JsonKey(name: "active") required bool active,
    @JsonKey(name: "options") required List<PickListOption> options,
  }) = _PickList;

  factory PickList.fromJson(Map<String, dynamic> json) =>
      _$PickListFromJson(json);
}

@freezed
abstract class PickListOption with _$PickListOption {
  const factory PickListOption({
    @JsonKey(name: "id") required String id,
    @JsonKey(name: "form_picklist_id") required String picklistId,
    @JsonKey(name: "form_picklist_option_name") required String name,
    @JsonKey(name: "form_picklist_option_description") String? description,
    @JsonKey(name: "active") required bool active,
  }) = _PickListOption;

  factory PickListOption.fromJson(Map<String, dynamic> json) =>
      _$PickListOptionFromJson(json);
}
