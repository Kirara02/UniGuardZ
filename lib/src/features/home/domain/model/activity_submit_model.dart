import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_submit_model.g.dart';
part 'activity_submit_model.freezed.dart';

@freezed
abstract class ActivitySubmitModel with _$ActivitySubmitModel {
  const factory ActivitySubmitModel({
    @JsonKey(name: "uuid") required String uuid,
    @JsonKey(name: "activity_id") String? activityId,
    @JsonKey(name: "activity_name") String? activityName,
    @JsonKey(name: "original_submitted_time")
    required String originalSubmittedTime,
    @JsonKey(name: "id") required String id,
  }) = _ActivitySubmitResponse;

  factory ActivitySubmitModel.fromJson(Map<String, dynamic> json) =>
      _$ActivitySubmitResponseFromJson(json);
}
