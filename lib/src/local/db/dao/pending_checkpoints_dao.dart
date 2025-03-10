import 'package:drift/drift.dart';
import 'package:ugz_app/src/local/db/uniguard_db.dart';

part 'pending_checkpoints_dao.g.dart';

@DriftAccessor(tables: [PendingCheckpoints])
class PendingCheckpointsDao extends DatabaseAccessor<UniguardDB>
    with _$PendingCheckpointsDaoMixin {
  final UniguardDB db;
  PendingCheckpointsDao(this.db) : super(db);

  Future<int> insertPendingCheckpoint({
    required PendingCheckpoints data,
  }) {
    return into(db.pendingCheckpoints).insert(
      PendingCheckpointsCompanion(
          partitionKey: Value(data.partitionKey),
          timestamp: Value(data.timestamp),
          latitude: Value(data.latitude),
          longitude: Value(data.longitude),
          type: const Value("value"),
          data: Value(Uint8List(2))),
    );
  }

  Future<bool> updatePendingCheckpoint({
    required int id,
    String? partitionKey,
    String? timestamp,
    double? latitude,
    double? longitude,
    String? type,
    Uint8List? data,
  }) async {
    final rowsUpdated = await (update(db.pendingCheckpoints)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      PendingCheckpointsCompanion(
        partitionKey:
            partitionKey != null ? Value(partitionKey) : const Value.absent(),
        timestamp: timestamp != null ? Value(timestamp) : const Value.absent(),
        latitude: latitude != null ? Value(latitude) : const Value.absent(),
        longitude: longitude != null ? Value(longitude) : const Value.absent(),
        type: type != null ? Value(type) : const Value.absent(),
        data: data != null ? Value(data) : const Value.absent(),
      ),
    );

    return rowsUpdated > 0;
  }

  Future<int> deleteAllPendingCheckpoint() async {
    return (delete(db.pendingCheckpoints)).go();
  }

  Future<int> deletePendingCheckpointById(int id) async {
    return (delete(db.pendingCheckpoints)..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  Stream<List<PendingCheckpoints>> getPendingCheckpointsByPartition({
    required String partitionKey,
  }) {
    return (select(db.pendingCheckpoints)
          ..where((tbl) => tbl.partitionKey.equals(partitionKey)))
        .watch();
  }

  Future<PendingCheckpoints?> getPendingCheckpointById(int id) {
    return (select(db.pendingCheckpoints)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<PendingCheckpoints>> getAllPendingCheckpoints(
      String partitionKey) {
    return (select(db.pendingCheckpoints)
          ..where((tbl) => tbl.partitionKey.equals(partitionKey)))
        .get();
  }
}
