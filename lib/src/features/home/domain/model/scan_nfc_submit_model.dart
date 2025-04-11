import 'package:freezed_annotation/freezed_annotation.dart';

part 'scan_nfc_submit_model.g.dart';
part 'scan_nfc_submit_model.freezed.dart';

@freezed
abstract class ScanNfcSubmitModel with _$ScanNfcSubmitModel {
  const factory ScanNfcSubmitModel({
    @JsonKey(name: "uuid") required String uuid,
    @JsonKey(name: "original_submitted_time")
    required DateTime originalSubmittedTime,
    @JsonKey(name: "id") required String id,
  }) = _ScanNfcSubmitModel;

  factory ScanNfcSubmitModel.fromJson(Map<String, dynamic> json) =>
      _$ScanNfcSubmitModelFromJson(json);
}
