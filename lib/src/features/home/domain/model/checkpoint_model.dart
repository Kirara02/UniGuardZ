import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkpoint_model.g.dart';
part 'checkpoint_model.freezed.dart';

@freezed
abstract class CheckpointModel with _$CheckpointModel {
  const factory CheckpointModel({
    required String id,
    required String uuid,
    @JsonKey(name: "major_value") double? majorValue,
    @JsonKey(name: "minor_value") double? minorValue,
    @JsonKey(name: "checkpoint_type") required CheckpointType checkpointType,
    @JsonKey(name: "checkpoint_name") String? checkpointName,
    @JsonKey(name: "checkpoint_description") String? checkpointDescription,
    @JsonKey(name: "serial_number_hex") String? serialNumberHex,
    @JsonKey(name: "serial_number_dec") String? serialNumberDec,
    @JsonKey(name: "serial_number_second_hex") String? secondSerialNumberHex,
    @JsonKey(name: "serial_number_second_dec") String? secondSerialNumberDec,
    @JsonKey(name: "beacon") Beacon? beacon,
    @JsonKey(name: "active") required bool active,
  }) = _CheckpointModel;

  factory CheckpointModel.fromJson(Map<String, dynamic> json) =>
      _$CheckpointModelFromJson(json);
}

@freezed
abstract class CheckpointType with _$CheckpointType {
  const factory CheckpointType({
    @JsonKey(name: "id") required String id,
    @JsonKey(name: "checkpoint_type_name") required String checkpointTypeName,
    @JsonKey(name: "checkpoint_type_description")
    String? checkpointTypeDescription,
  }) = _CheckpointType;

  factory CheckpointType.fromJson(Map<String, dynamic> json) =>
      _$CheckpointTypeFromJson(json);
}

@freezed
abstract class Beacon with _$Beacon {
  const factory Beacon({
    @JsonKey(name: "id") required String id,
    @JsonKey(name: "beacon_name") required String checkpointTypeName,
    @JsonKey(name: "beacon_uuid") required String checkpointTypeDescription,
    @JsonKey(name: "counter_customer_code") String? counterCustomerCode,
  }) = _Beacon;

  factory Beacon.fromJson(Map<String, dynamic> json) => _$BeaconFromJson(json);
}
