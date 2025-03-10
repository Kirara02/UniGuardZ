import 'dart:io';

class SubmitActivityParams {
  final String id;
  final double? latitude;
  final double? longitude;
  final String? comment;
  final File? photo;
  final DateTime timestamp;

  SubmitActivityParams({
    required this.id,
    this.latitude,
    this.longitude,
    this.comment,
    this.photo,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
