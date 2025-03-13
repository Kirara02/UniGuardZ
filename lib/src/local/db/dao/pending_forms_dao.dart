import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:ugz_app/src/constants/enum.dart';
import 'package:ugz_app/src/local/record/form_data.dart';
import 'package:ugz_app/src/local/db/uniguard_db.dart';
import 'package:ugz_app/src/utils/misc/print.dart';

part 'pending_forms_dao.g.dart';

@DriftAccessor(tables: [PendingForms])
class PendingFormsDao extends DatabaseAccessor<UniguardDB>
    with _$PendingFormsDaoMixin {
  final UniguardDB db;
  PendingFormsDao(this.db) : super(db);

  Future<int> insertPendingForm({required PendingForms data}) async {
    final form = await getPendingFormByFormId(data.formId);

    if (form != null) {
      await deletePendingFormById(form.id);
    }

    return into(db.pendingForms).insert(
      PendingFormsCompanion(
        partitionKey: Value(data.partitionKey),
        timestamp: Value(data.timestamp),
        latitude: Value(data.latitude),
        longitude: Value(data.longitude),
        description: Value(data.description),
        category: Value(data.category),
        formId: Value(data.formId),
        data: Value(data.data),
      ),
    );
  }

  Future<bool> updatePendingForm({
    required int id,
    String? partitionKey,
    String? timestamp,
    double? latitude,
    double? longitude,
    String? description,
    PendingFormCategory? category,
    String? formId,
    FormData? data,
  }) async {
    final rowsUpdated = await (update(db.pendingForms)
      ..where((tbl) => tbl.id.equals(id))).write(
      PendingFormsCompanion(
        partitionKey:
            partitionKey != null ? Value(partitionKey) : const Value.absent(),
        timestamp: timestamp != null ? Value(timestamp) : const Value.absent(),
        latitude: latitude != null ? Value(latitude) : const Value.absent(),
        longitude: longitude != null ? Value(longitude) : const Value.absent(),
        description:
            description != null ? Value(description) : const Value.absent(),
        category:
            category != null ? Value(category.value) : const Value.absent(),
        formId: formId != null ? Value(formId) : const Value.absent(),
        data:
            data != null
                ? Value(jsonEncode(data.toJson()))
                : const Value.absent(),
      ),
    );

    return rowsUpdated > 0;
  }

  Future<int> deleteAllPendingForms() async {
    final allPendingForms = await (select(db.pendingForms).get());

    for (final form in allPendingForms) {
      if (form.data.isNotEmpty) {
        try {
          final dataMap = jsonDecode(form.data) as Map<String, dynamic>;
          await _deleteFilesFromCache(dataMap['signatures'] as List<dynamic>?);
        } catch (e) {
          printIfDebug('Error processing form data: ${form.id}, error: $e');
        }
      }
    }

    return (delete(db.pendingForms)).go();
  }

  Future<int> deletePendingFormById(int id) async {
    final form =
        await (select(db.pendingForms)
          ..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

    if (form != null && form.data.isNotEmpty) {
      try {
        final dataMap = jsonDecode(form.data) as Map<String, dynamic>;
        await _deleteFilesFromCache(dataMap['signatures'] as List<dynamic>?);
      } catch (e) {
        printIfDebug('Error processing form data for ID $id, error: $e');
      }
    }

    return (delete(db.pendingForms)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<List<PendingForms>> getPendingFormsByCategory({
    required PendingFormCategory category,
    required String partitionKey,
  }) {
    return (select(db.pendingForms)..where(
      (tbl) =>
          tbl.category.equals(category.value) &
          tbl.partitionKey.equals(partitionKey),
    )).get();
  }

  Future<List<PendingForms>> getPendingFormsByPartition({
    required String partitionKey,
  }) {
    return (select(db.pendingForms)
          ..where((tbl) => tbl.partitionKey.equals(partitionKey))
          ..orderBy([
            (tbl) => OrderingTerm(
              expression: tbl.timestamp,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Stream<List<PendingForms>> streamPendingFormsByPartition({
    required String partitionKey,
  }) {
    return (select(db.pendingForms)
          ..where((tbl) => tbl.partitionKey.equals(partitionKey))
          ..orderBy([
            (tbl) => OrderingTerm(
              expression: tbl.timestamp,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  Future<PendingForms?> getPendingFormById(int id) {
    return (select(db.pendingForms)
      ..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<PendingForms?> getPendingFormByFormId(String formId) async {
    print("hello from local db");
    return await (select(db.pendingForms)
      ..where((tbl) => tbl.formId.equals(formId))).getSingleOrNull();
  }

  Future<List<PendingForms>> getAllPendingForms(String partitionKey) {
    return (select(db.pendingForms) 
      ..where((tbl) => tbl.partitionKey.equals(partitionKey))).get();
  }

  Stream<int> count(String partitionKey) {
    return (select(db.pendingForms)..where(
      (tbl) => tbl.partitionKey.equals(partitionKey),
    )).watch().map((list) => list.length);
  }

  Future<void> _deleteFilesFromCache(List<dynamic>? entries) async {
    if (entries == null || entries.isEmpty) return;

    for (final entry in entries) {
      if (entry is Map<String, dynamic>) {
        final filePath = entry['value'] as String?;
        if (filePath != null && filePath.isNotEmpty) {
          await _deleteFile(filePath);
        }
      }
    }
  }

  Future<void> _deleteFile(String filePath) async {
    final file = File(filePath);

    if (await file.exists()) {
      try {
        await file.delete();
        printIfDebug('Deleted cached signature: $filePath');
      } catch (e) {
        printIfDebug('Failed to delete file: $filePath, error: $e');
      }
    } else {
      printIfDebug('File not found: $filePath');
    }
  }
}
