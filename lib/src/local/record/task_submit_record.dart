import 'package:ugz_app/src/local/record/form_data.dart';

class TaskSubmitRecord {
  final String partitionKey;
  final String timestamp;
  final double? latitude;
  final double? longitude;
  final String description;
  final String formId;
  final FormData data;

  TaskSubmitRecord(
      {required this.partitionKey,
      required this.timestamp,
      required this.latitude,
      required this.longitude,
      required this.description,
      required this.formId,
      required this.data});
}
