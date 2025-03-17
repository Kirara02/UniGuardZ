import 'package:freezed_annotation/freezed_annotation.dart';

part 'payload_data_form_model.g.dart';
part 'payload_data_form_model.freezed.dart';

@freezed
abstract class PayloadDataFormModel with _$PayloadDataFormModel {
  const factory PayloadDataFormModel({
    @JsonKey(name: "type") required String type,
    @JsonKey(name: "logForm") required LogFormModel logForm,
    @JsonKey(name: "fields") required List<PayloadFormFieldModel> fields,
  }) = _PayloadDataFormModel;

  factory PayloadDataFormModel.fromJson(Map<String, dynamic> json) =>
      _$PayloadDataFormModelFromJson(json);
}

@freezed
abstract class LogFormModel with _$LogFormModel {
  const factory LogFormModel({
    @JsonKey(name: "uuid") required String uuid,
    @JsonKey(name: "form_id") required String formId,
    @JsonKey(name: "form_name") required String formName,
    @JsonKey(name: "original_submitted_time")
    required String originalSubmittedTime,
    @JsonKey(name: "latitude") double? latitude,
    @JsonKey(name: "longitude") double? longitude,
  }) = _LogFormModel;

  factory LogFormModel.fromJson(Map<String, dynamic> json) =>
      _$LogFormModelFromJson(json);
}

@freezed
abstract class PayloadFormFieldModel with _$PayloadFormFieldModel {
  const factory PayloadFormFieldModel({
    @JsonKey(name: "id") required String id,
    @JsonKey(name: "log_form_id") required String logFormId,
    @JsonKey(name: "field_type_id") required int fieldTypeId,
    @JsonKey(name: "field_type_name") required String fieldTypeName,
    @JsonKey(name: "form_field_name") required String formFieldName,
    @JsonKey(name: "field_type_value")  String? fieldTypeValue,
  }) = _PayloadFormFieldModel;

  factory PayloadFormFieldModel.fromJson(Map<String, dynamic> json) =>
      _$PayloadFormFieldModelFromJson(json);
}

