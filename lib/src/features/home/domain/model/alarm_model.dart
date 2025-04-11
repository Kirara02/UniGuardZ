import 'package:freezed_annotation/freezed_annotation.dart';

part 'alarm_model.freezed.dart';
part 'alarm_model.g.dart';

@freezed
abstract class AlarmModel with _$AlarmModel {
  const factory AlarmModel({
    @JsonKey(name: "uuid") required String uuid,
    @JsonKey(name: "original_submitted_time")
    required DateTime originalSubmittedTime,
    @JsonKey(name: "id") required String id,
  }) = _AlarmModel;

  factory AlarmModel.fromJson(Map<String, dynamic> json) =>
      _$AlarmModelFromJson(json);
}
