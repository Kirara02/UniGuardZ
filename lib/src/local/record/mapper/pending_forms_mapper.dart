import 'dart:convert';

import 'package:ugz_app/src/local/db/uniguard_db.dart';
import 'package:ugz_app/src/local/record/pending_forms_model.dart';

class PendingFormsMapper {
  static PendingFormsModel mapToModel(PendingForms data) {
    return PendingFormsModel(
      id: data.id,
      partitionKey: data.partitionKey,
      timestamp: data.timestamp,
      description: data.description,
      category: data.category,
      latitude: data.latitude,
      longitude: data.longitude,
      formId: data.formId,
      data: jsonDecode(data.data),
    );
  }

  static PendingForms mapToEntity(PendingFormsModel model) {
    return PendingForms(
      id: model.id,
      partitionKey: model.partitionKey,
      timestamp: model.timestamp,
      latitude: model.latitude,
      longitude: model.longitude,
      description: model.description,
      category: model.category,
      formId: model.formId,
      data: jsonEncode(model.data),
    );
  }
}
