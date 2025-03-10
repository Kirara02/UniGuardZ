import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:ugz_app/src/local/db/dao/pending_checkpoints_dao.dart';
import 'package:ugz_app/src/local/db/dao/pending_forms_dao.dart';
import 'package:ugz_app/src/local/db/dao/pending_locations_dao.dart';

part 'uniguard_db.g.dart';

@DriftDatabase(include: {'sql.drift'})
class UniguardDB extends _$UniguardDB {
  static final UniguardDB _instance = UniguardDB();

  static UniguardDB instance() => _instance;

  UniguardDB() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {}
      },
      beforeOpen: (details) async {},
    );
  }

  PendingFormsDao get pendingFormsDao => PendingFormsDao(this);
  PendingCheckpointsDao get pendingCheckpointsDao => PendingCheckpointsDao(this);
  PendingLocationsDao get pendingLocationsDao => PendingLocationsDao(this);
}

// LazyDatabase initialization
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
