import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';
import 'package:uuid/uuid.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Mib3, Setting])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<Mib3Data>> getAll() => select(mib3).get();
  Stream<List<Mib3Data>> watchAll() => select(mib3).watch();

  Future<void> insertRow(Mib3Companion row) {
    return into(mib3).insert(row, mode: InsertMode.insertOrReplace);
  }

  Future<void> deleteRow(String id) {
    return (delete(mib3)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateRow(Mib3Companion row) =>
      (update(mib3)..where((t) => t.id.equals(row.id.value))).write(
        Mib3Companion(
          tb: row.tb,
          wan: row.wan,
          content: row.content,
        ),
      );

  Future<List<SettingData>> getAllSettings() => select(setting).get();
  Future<void> insertSetting(SettingCompanion row) =>
      into(setting).insert(row, mode: InsertMode.insertOrReplace);
}


LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'mib3.db'));
    return NativeDatabase(file);
  });
}
