import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Mib3, Mib3Sub, Setting])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  static final AppDatabase instance = AppDatabase._internal();

  factory AppDatabase() => instance;

  @override
  int get schemaVersion => 1;

  Future<List<Mib3SubData>> getSubsByMaster(String masterId) {
    return (select(mib3Sub)
      ..where((t) => t.masterId.equals(masterId))
      ..orderBy([
            (t) => OrderingTerm.asc(t.sdate),
      ]))
        .get();
  }

  Future<void> clearAll() async {
    await batch((b) {
      b.deleteAll(mib3);
      b.deleteAll(mib3Sub);
    });
  }

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

  /// 🔹 setting 전체 읽기
  Future<List<SettingData>> getAllSettings() =>
      select(setting).get();

  /// 🔹 setting 1개 upsert
  Future<void> setSetting(String id, String value) =>
      into(setting).insert(
        SettingCompanion(
          id: Value(id),
          content: Value(value),
        ),
        mode: InsertMode.insertOrReplace,
      );

  /// 🔹 setting 값 하나 가져오기
  Future<String?> getSetting(String id) async {
    final row =
    await (select(setting)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row?.content;
  }

  /// ⭐ 여기서 초기 데이터 생성
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();

      // 기본 setting 값
      await batch((b) {
        b.insertAll(setting, [
          SettingCompanion.insert(id: 'theme', content: 'system'),
          SettingCompanion.insert(id: 'font', content: 'OpenSans-Medium'),
          SettingCompanion.insert(id: 'font_size', content: '14'),
          SettingCompanion.insert(id: 'view_font_size', content: '16'),
          SettingCompanion.insert(id: 'line_size', content: '10'),
        ]);
      });
    },
  );

  Stream<List<MibWithLastSubDate>> watchJinWithLastSubDate() {
    return customSelect(
      '''
    SELECT
      m.*,
      MAX(s.sdate) AS last_sub_date
    FROM mib3 m
    LEFT JOIN mib3_sub s ON s.master_id = m.id
    WHERE m.tb = '진행'
    GROUP BY m.id
    ''',
      readsFrom: {mib3, mib3Sub},
    ).watch().map((rows) {
      return rows.map((row) {
        final lastSubDateStr = row.read<String?>('last_sub_date');

        return MibWithLastSubDate(
          memo: mib3.map(row.data),
          lastSubDate: lastSubDateStr, // 이미 yyyy-MM-dd
          // 또는 필요하면 DateTime.parse(lastSubDateStr!)
        );
      }).toList();
    });
  }

  Future<void> insertSub(Mib3SubCompanion row) {
    return into(mib3Sub).insert(row, mode: InsertMode.insertOrReplace);
  }

  Future<void> deleteSub(String id) {
    return (delete(mib3Sub)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteSubsByMaster(String masterId) {
    return (delete(mib3Sub)..where((t) => t.masterId.equals(masterId))).go();
  }

  /// 🔹 mib3_sub 내용 수정
  Future<void> updateSub({
    required String id,
    String? sdate,
    String? content,
  }) {
    return (update(mib3Sub)..where((t) => t.id.equals(id))).write(
      Mib3SubCompanion(
        content: content != null ? Value(content) : const Value.absent(),
        sdate: sdate != null ? Value(sdate) : const Value.absent(),
      ),
    );
  }
}

/// 🔹 스트림 버전 (Obs로 쓰고 싶으면)


class MibWithLastSubDate {
  final Mib3Data memo;
  final String? lastSubDate;

  MibWithLastSubDate({required this.memo, this.lastSubDate});
}


LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'mib3.db'));
    return NativeDatabase(file);
  });
}
