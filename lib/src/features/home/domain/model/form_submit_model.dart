import 'package:freezed_annotation/freezed_annotation.dart';

part 'form_submit_model.freezed.dart';
part 'form_submit_model.g.dart';

@freezed
abstract class FormSubmitModel with _$FormSubmitModel {
  const factory FormSubmitModel({
    @JsonKey(name: "uuid") required String uuid,
    @JsonKey(name: "form_id") required String formId,
    @JsonKey(name: "form_name") required String formName,
    @JsonKey(name: "original_submitted_time")
    required String originalSubmittedTime,
    @JsonKey(name: "id") required String id,
  }) = _FormSubmitModel;

  factory FormSubmitModel.fromJson(Map<String, dynamic> json) =>
      _$FormSubmitModelFromJson(json);
}
