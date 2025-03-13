import 'package:ugz_app/src/local/record/activity_log_submit_record.dart';
import 'package:ugz_app/src/local/record/form_submit_record.dart';
import 'package:ugz_app/src/local/record/pending_forms_model.dart';
import 'package:ugz_app/src/local/record/task_submit_record.dart';

abstract interface class PendingFormsRepository {
  Future<int> insertActivity({required ActivityLogSubmitRecord record});

  Future<int> insertTask({required TaskSubmitRecord record});

  Future<int> insertForm({required FormSubmitRecord record});

  Future<int> deleteAll();

  Future<int> deleteById(int id);

  Stream<List<PendingFormsModel>> streamUsersHistories({
    required String partitionKey,
  });
  Future<List<PendingFormsModel>> getUsersHistories({
    required String partitionKey,
  });

  Future<PendingFormsModel?> getById(int id);

  Future<PendingFormsModel?> getByFormId(String formId);

  Stream<int> count({required String partitionKey});
}
