
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../widgets/interface/base_field.dart';
import 'field_model.dart';


part 'form_model.freezed.dart';
part 'form_model.g.dart';

@freezed
abstract class FormModel with _$FormModel {
  const factory FormModel({
    @JsonKey(name: "id") required String id,
    @JsonKey(name: "parent_branch_id") required String parentBranchId,
    @JsonKey(name: "role_id") String? roleId,
    @JsonKey(name: "checkpoint_id") String? checkpointId,
    @JsonKey(name: "form_name") required String formName,
    @JsonKey(name: "form_description") required String formDescription,
    @JsonKey(name: "active") required bool active,
    @JsonKey(name: "created_at") required DateTime createdAt,
    @JsonKey(name: "created_by") String? createdBy,
    @JsonKey(name: "updated_at") required DateTime updatedAt,
    @JsonKey(name: "updated_by") String? updatedBy,
    @JsonKey(name: "fields") required List<FormFields> fields,
  }) = _FormModel;

  factory FormModel.fromJson(Map<String, dynamic> json) =>
      _$FormModelFromJson(json);
}

@freezed
abstract class FormFields with _$FormFields implements BaseField {
  const FormFields._();

  const factory FormFields({
    @JsonKey(name: "id") required String id,
    @JsonKey(name: "form_id") required String formId,
    @JsonKey(name: "field_type_id") required String fieldTypeId,
    @JsonKey(name: "form_picklist_id") String? formPicklistId,
    @JsonKey(name: "form_field_name") required String formFieldName,
    @JsonKey(name: "form_field_description") String? formFieldDescription,
    @JsonKey(name: "form_field_require") required bool formFieldRequire,
    @JsonKey(name: "active") required bool active,
    @JsonKey(name: "created_at") required DateTime createdAt,
    @JsonKey(name: "created_by") String? createdBy,
    @JsonKey(name: "updated_at") required DateTime updatedAt,
    @JsonKey(name: "updated_by") String? updatedBy,
    @JsonKey(name: "field_type") required FieldType fieldType,
    @JsonKey(name: "picklist") PickList? picklist,
  }) = _FormFields;

  factory FormFields.fromJson(Map<String, dynamic> json) =>
      _$FormFieldsFromJson(json);

  @override
  bool get IActive => active;

  @override
  String get IFieldName => formFieldName;

  @override
  String get IFieldTypeId => fieldTypeId;

  @override
  String get Iid => id;

  @override
  bool get IRequired => formFieldRequire;

  @override
  PickList? get IPickList => picklist;
}
