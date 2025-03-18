import 'package:freezed_annotation/freezed_annotation.dart';

part 'payload_data_location_model.g.dart';
part 'payload_data_location_model.freezed.dart';

@freezed
abstract class PayloadDataLocationModel with _$PayloadDataLocationModel {
  const factory PayloadDataLocationModel({
    @JsonKey(name: "type") required String type,
    @JsonKey(name: "logGeolocation") required LogLocationModel logLocation,
  }) = _PayloadDataLocationModel;

  factory PayloadDataLocationModel.fromJson(Map<String, dynamic> json) =>
      _$PayloadDataLocationModelFromJson(json);
}

@freezed
abstract class LogLocationModel with _$LogLocationModel {
  const factory LogLocationModel({
    @JsonKey(name: "uuid") required String uuid,
    @JsonKey(name: "original_submitted_time")
    required String originalSubmittedTime,
    @JsonKey(name: "latitude") double? latitude,
    @JsonKey(name: "longitude") double? longitude,
  }) = _LogLocationModel;

  factory LogLocationModel.fromJson(Map<String, dynamic> json) =>
      _$LogLocationModelFromJson(json);
}
