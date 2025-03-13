import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/constants/enum.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';
import 'package:ugz_app/src/local/db/uniguard_db.dart';
import 'package:ugz_app/src/local/interface/pending_forms_repository.dart';
import 'package:ugz_app/src/local/record/activity_log_submit_record.dart';
import 'package:ugz_app/src/local/record/form_submit_record.dart';
import 'package:ugz_app/src/local/record/mapper/pending_forms_mapper.dart';
import 'package:ugz_app/src/local/record/pending_forms_model.dart';
import 'package:ugz_app/src/local/record/task_submit_record.dart';

part 'pending_forms_repository_impl.g.dart';

class PendingFormsRepositoryImpl implements PendingFormsRepository {
  final UniguardDB db;

  PendingFormsRepositoryImpl({required this.db});

  @override
  Future<int> deleteById(int id) async {
    return db.pendingFormsDao.deletePendingFormById(id);
  }

  @override
  Future<PendingFormsModel?> getById(int id) async {
    final entity = await db.pendingFormsDao.getPendingFormById(id);
    return entity != null ? PendingFormsMapper.mapToModel(entity) : null;
  }

  @override
  Stream<List<PendingFormsModel>> streamUsersHistories({
    required String partitionKey,
  }) {
    final entities = db.pendingFormsDao.streamPendingFormsByPartition(
      partitionKey: partitionKey,
    );
    return entities.map(
      (list) => list.map(PendingFormsMapper.mapToModel).toList(),
    );
  }

  @override
  Future<int> insertActivity({required ActivityLogSubmitRecord record}) {
    final model = PendingFormsModel(
      id: 0,
      partitionKey: record.partitionKey,
      timestamp: DateTime.parse(record.timestamp),
      latitude: record.latitude,
      longitude: record.longitude,
      category: PendingFormCategory.activity.value,
      description: record.description,
      formId: record.formId,
      data: record.data.toJson(),
    );

    return db.pendingFormsDao.insertPendingForm(
      data: PendingFormsMapper.mapToEntity(model),
    );
  }

  @override
  Future<int> insertForm({required FormSubmitRecord record}) {
    final model = PendingFormsModel(
      id: 0,
      partitionKey: record.partitionKey,
      timestamp: DateTime.parse(record.timestamp),
      latitude: record.latitude,
      longitude: record.longitude,
      category: PendingFormCategory.forms.value,
      description: record.description,
      formId: record.formId,
      data: record.data.toJson(),
    );

    return db.pendingFormsDao.insertPendingForm(
      data: PendingFormsMapper.mapToEntity(model),
    );
  }

  @override
  Future<int> insertTask({required TaskSubmitRecord record}) {
    final model = PendingFormsModel(
      id: 0,
      partitionKey: record.partitionKey,
      timestamp: DateTime.parse(record.timestamp),
      latitude: record.latitude,
      longitude: record.longitude,
      category: PendingFormCategory.tasks.value,
      description: record.description,
      formId: record.formId,
      data: record.data.toJson(),
    );

    return db.pendingFormsDao.insertPendingForm(
      data: PendingFormsMapper.mapToEntity(model),
    );
  }

  @override
  Future<int> deleteAll() async {
    return db.pendingFormsDao.deleteAllPendingForms();
  }

  @override
  Stream<int> count({required String partitionKey}) {
    return db.pendingFormsDao.count(partitionKey);
  }

  @override
  Future<List<PendingFormsModel>> getUsersHistories({
    required String partitionKey,
  }) async {
    final entities = await db.pendingFormsDao.getPendingFormsByPartition(
      partitionKey: partitionKey,
    );
    return entities.map(PendingFormsMapper.mapToModel).toList();
  }
}

@riverpod
PendingFormsRepository pendingFormsRepository(PendingFormsRepositoryRef ref) =>
    PendingFormsRepositoryImpl(db: ref.watch(appDatabaseProvider));
