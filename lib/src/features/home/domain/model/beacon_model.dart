import 'package:freezed_annotation/freezed_annotation.dart';

part 'beacon_model.g.dart';
part 'beacon_model.freezed.dart';

@freezed
abstract class BeaconModel with _$BeaconModel {
  const factory BeaconModel({
    required String id,
    required String uuid,
    @JsonKey(name: "major_value") required double majorValue,
    @JsonKey(name: "minor_value") required double minorValue,
  }) = _BeaconModel;

  factory BeaconModel.fromJson(Map<String, dynamic> json) =>
      _$BeaconModelFromJson(json);
}
