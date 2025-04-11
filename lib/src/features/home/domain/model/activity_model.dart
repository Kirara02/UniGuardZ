import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_model.freezed.dart';
part 'activity_model.g.dart';

@freezed
abstract class ActivityModel with _$ActivityModel {
  const factory ActivityModel({
    @JsonKey(name: "id") required String id,
    @JsonKey(name: "activity_name") required String activityName,
    @JsonKey(name: "activity_description") required String activityDescription,
    @JsonKey(name: "gps_required") required bool gpsRequired,
    @JsonKey(name: "photo_required") required bool photoRequired,
    @JsonKey(name: "comment_required") required bool commentRequired,
    @JsonKey(name: "active") required bool active,
    @JsonKey(name: "created_at") required DateTime createdAt,
    @JsonKey(name: "created_by") String? createdBy,
    @JsonKey(name: "updated_at") required DateTime updatedAt,
    @JsonKey(name: "updated_by") String? updatedBy,
  }) = _ActivityModel;

  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);
}