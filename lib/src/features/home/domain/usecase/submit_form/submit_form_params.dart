import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:ugz_app/src/utils/misc/print.dart';

class SubmitFormParams {
  final String id;
  final double longitude;
  final double latitude;
  final String timestamp;
  final List<FormField> fields;
  final List<FormPhoto> photos;

  SubmitFormParams({
    required this.id,
    required this.longitude,
    required this.latitude,
    required this.timestamp,
    required this.fields,
    required this.photos,
  });

  Map<String, dynamic> toJson() {
    return {
      "longitude": longitude.toString(),
      "latitude": latitude.toString(),
      "original_submitted_time": timestamp,
      "fields": fields.map((f) => f.toJson()).toList(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  Future<Map<String, MultipartFile>> toMultipartFiles() async {
    final Map<String, MultipartFile> files = {};

    for (var photo in photos) {
      if (photo.filePath != null && photo.filePath!.isNotEmpty) {
        File file = File(photo.filePath!);
        if (file.existsSync()) {
          String originalFilename = path.basename(photo.filePath!);
          printIfDebug("✅ Photo found: $originalFilename");

          files["file_${photo.id}"] = await MultipartFile.fromFile(
            file.path,
            filename: originalFilename,
          );
        } else {
          printIfDebug("⚠️ File not found: ${photo.filePath}");
        }
      }
    }
    return files;
  }
}

class FormField {
  final String id;
  final String fieldTypeId;
  final String fieldTypeName;
  final String taskFieldName;
  final String value;

  FormField({
    required this.id,
    required this.fieldTypeId,
    required this.fieldTypeName,
    required this.taskFieldName,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "field_type_id": fieldTypeId,
    "field_type_name": fieldTypeName,
    "task_field_name": taskFieldName,
    "value": value,
  };
}

class FormPhoto {
  final String id;
  final String? filePath;

  FormPhoto({required this.id, required this.filePath});
}
