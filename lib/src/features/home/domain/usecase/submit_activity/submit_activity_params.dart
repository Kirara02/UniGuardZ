import 'dart:io';

class SubmitActivityParams {
  final String id;
  final double? latitude;
  final double? longitude;
  final String? comment;
  final File? photo;
  final String timestamp;

  SubmitActivityParams({
    required this.id,
    this.latitude,
    this.longitude,
    this.comment,
    this.photo,
    required this.timestamp,
  });
}
