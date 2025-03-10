import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:ugz_app/src/utils/misc/print.dart';

class SubmitTaskParams {
  final String id;
  final double longitude;
  final double latitude;
  final String timestamp;
  final List<TaskField> fields;
  final List<TaskPhoto> photos;

  SubmitTaskParams({
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
        files["file_${photo.id}"] = await MultipartFile.fromFile(
            photo.filePath!,
            filename: "image-${photo.id}.jpg");

        printIfDebug(files["file_${photo.id}"]?.headers);
      }
    }
    return files;
  }
}

class TaskField {
  final String id;
  final String fieldTypeId;
  final String fieldTypeName;
  final String taskFieldName;
  final String value;

  TaskField({
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

class TaskPhoto {
  final String id;
  final String? filePath;

  TaskPhoto({required this.id, required this.filePath});
}
