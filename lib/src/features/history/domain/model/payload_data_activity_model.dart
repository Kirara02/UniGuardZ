import 'package:freezed_annotation/freezed_annotation.dart';

part 'payload_data_activity_model.g.dart';
part 'payload_data_activity_model.freezed.dart';

@freezed
abstract class PayloadDataActivityModel with _$PayloadDataActivityModel {
  const factory PayloadDataActivityModel({
    @JsonKey(name: "type") required String type,
    @JsonKey(name: "logActivity") required LogActivityModel logActivity,
  }) = _PayloadDataActivityModel;

  factory PayloadDataActivityModel.fromJson(Map<String, dynamic> json) =>
      _$PayloadDataActivityModelFromJson(json);
}

@freezed
abstract class LogActivityModel with _$LogActivityModel {
  const factory LogActivityModel({
    @JsonKey(name: "uuid") required String uuid,
    @JsonKey(name: "activity_id") required String activityId,
    @JsonKey(name: "activity_name") required String activityName,
    @JsonKey(name: "original_submitted_time")
    required String originalSubmittedTime,
    @JsonKey(name: "comment") String? comment,
    @JsonKey(name: "latitude") double? latitude,
    @JsonKey(name: "longitude") double? longitude,
    @JsonKey(name: "photo_url") String? photoUrl,
  }) = _LogActivityModel;

  factory LogActivityModel.fromJson(Map<String, dynamic> json) =>
      _$LogActivityModelFromJson(json);
}
