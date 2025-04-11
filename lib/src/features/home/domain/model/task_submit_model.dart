import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_submit_model.freezed.dart';
part 'task_submit_model.g.dart';

@freezed
abstract class TaskSubmitModel with _$TaskSubmitModel {
  const factory TaskSubmitModel({
    @JsonKey(name: 'uuid') required String uuid,
    @JsonKey(name: 'task_id') required int taskId,
    @JsonKey(name: 'task_name') required String taskName,
    @JsonKey(name: 'task_type') required String taskType,
    @JsonKey(name: 'original_submitted_time')
    required String originalSubmittedTime,
    @JsonKey(name: 'id') required String id,
  }) = _TaskSubmitModel;

  factory TaskSubmitModel.fromJson(Map<String, dynamic> json) =>
      _$TaskSubmitModelFromJson(json);
}
