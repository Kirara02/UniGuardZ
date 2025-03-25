import 'package:freezed_annotation/freezed_annotation.dart';

part 'nfc_tag_model.freezed.dart';
part 'nfc_tag_model.g.dart';

@freezed
abstract class NfcTagModel with _$NfcTagModel {
  const factory NfcTagModel({
    required String uid,
    required String type,
    required Map<String, dynamic> rawData,
    List<dynamic>? message,
  }) = _NfcTagModel;

  factory NfcTagModel.fromJson(Map<String, dynamic> json) =>
      _$NfcTagModelFromJson(json);
}
