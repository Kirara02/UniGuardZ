import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:ugz_app/src/constants/enum.dart';

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
        final File file = File(photo.filePath!);

        if (await file.exists()) {
          // Determine content type
          final mimeType = lookupMimeType(photo.filePath!) ?? 'image/jpeg';

          // Ensure we're only sending image files
          if (mimeType.startsWith('image/')) {
            final filename = path.basename(photo.filePath!);

            switch (photo.type) {
              case FileType.File:
                files["file_${photo.id}"] = await MultipartFile.fromFile(
                  photo.filePath!,
                  filename: "image-${photo.id}${path.extension(filename)}",
                  contentType: MediaType.parse(mimeType),
                );
                break;
              case FileType.Signature:
                files["file_${photo.id}"] = await MultipartFile.fromFile(
                  photo.filePath!,
                  filename: "signature-${photo.id}${path.extension(filename)}",
                  contentType: MediaType.parse(mimeType),
                );
                break;
              case null:
                break;
            }
          } else {
            print('Skipping non-image file: ${photo.filePath}');
          }
        } else {
          print('File does not exist: ${photo.filePath}');
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
  final String formFieldName;
  final String value;

  FormField({
    required this.id,
    required this.fieldTypeId,
    required this.fieldTypeName,
    required this.formFieldName,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "field_type_id": fieldTypeId,
    "field_type_name": fieldTypeName,
    "form_field_name": formFieldName,
    "value": value,
  };
}

class FormPhoto {
  final String id;
  final String? filePath;
  final FileType? type;

  FormPhoto({required this.id, required this.filePath, this.type});
}
