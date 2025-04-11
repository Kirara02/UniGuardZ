import 'package:freezed_annotation/freezed_annotation.dart';

part 'payload_data_user_model.g.dart';
part 'payload_data_user_model.freezed.dart';

@freezed
abstract class PayloadDataUserModel with _$PayloadDataUserModel {
  const factory PayloadDataUserModel({
    @JsonKey(name: "type") required String type,
    @JsonKey(name: "logUserDevice") required LogUserModel logUser,
  }) = _PayloadDataUserModel;

  factory PayloadDataUserModel.fromJson(Map<String, dynamic> json) =>
      _$PayloadDataUserModelFromJson(json);
}

@freezed
abstract class LogUserModel with _$LogUserModel {
  const factory LogUserModel({
    @JsonKey(name: "uuid") required String uuid,
    @JsonKey(name: "device_name") String? deviceName,
    @JsonKey(name: "event_time") required String eventTime,
  }) = _LogUserModel;

  factory LogUserModel.fromJson(Map<String, dynamic> json) =>
      _$LogUserModelFromJson(json);
}
