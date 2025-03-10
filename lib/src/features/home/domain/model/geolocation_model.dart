import 'package:freezed_annotation/freezed_annotation.dart';

part 'geolocation_model.g.dart';
part 'geolocation_model.freezed.dart';

@freezed
abstract class GeolocationModel with _$GeolocationModel {
  const factory GeolocationModel({
    required double latitude,
    required double longitude,
    @JsonKey(name: "original_submitted_time")
    required String originalSubmittedTime,
  }) = _GeolocationModel;

  factory GeolocationModel.fromJson(Map<String, dynamic> json) =>
      _$GeolocationModelFromJson(json);
}
