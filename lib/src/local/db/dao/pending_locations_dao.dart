import 'package:drift/drift.dart';
import 'package:ugz_app/src/local/db/uniguard_db.dart';

part 'pending_locations_dao.g.dart';

@DriftAccessor(tables: [PendingLocations])
class PendingLocationsDao extends DatabaseAccessor<UniguardDB>
    with _$PendingLocationsDaoMixin {
  final UniguardDB db;
  PendingLocationsDao(this.db) : super(db);

  Future<int> insertPendingForm({
    required PendingLocations data,
  }) {
    return into(db.pendingLocations).insert(
      PendingLocationsCompanion(
        partitionKey: Value(data.partitionKey),
        timestamp: Value(data.timestamp),
        latitude: Value(data.latitude),
        longitude: Value(data.longitude),
      ),
    );
  }

  Future<bool> updatePendingForm({
    required int id,
    String? partitionKey,
    String? timestamp,
    double? latitude,
    double? longitude,
  }) async {
    final rowsUpdated = await (update(db.pendingLocations)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      PendingLocationsCompanion(
        partitionKey:
            partitionKey != null ? Value(partitionKey) : const Value.absent(),
        timestamp: timestamp != null ? Value(timestamp) : const Value.absent(),
        latitude: latitude != null ? Value(latitude) : const Value.absent(),
        longitude: longitude != null ? Value(longitude) : const Value.absent(),
      ),
    );

    return rowsUpdated > 0;
  }

  Future<int> deleteAllPendingLocations() async {
    return (delete(db.pendingLocations)).go();
  }

  Future<int> deletePendingLocationById(int id) async {
    return (delete(db.pendingLocations)..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  Stream<List<PendingForms>> getPendingLocationsByPartition({
    required String partitionKey,
  }) {
    return (select(db.pendingForms)
          ..where((tbl) => tbl.partitionKey.equals(partitionKey)))
        .watch();
  }

  Future<PendingForms?> getPendingFormById(int id) {
    return (select(db.pendingForms)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<PendingForms>> getAllPendingForms(String partitionKey) {
    return (select(db.pendingForms)
          ..where((tbl) => tbl.partitionKey.equals(partitionKey)))
        .get();
  }

  Future<List<PendingLocations>> getAllPendingLocations(String partitionKey) {
    return (select(db.pendingLocations)
          ..where((tbl) => tbl.partitionKey.equals(partitionKey)))
        .get();
  }
}
