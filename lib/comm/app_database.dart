import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';
import 'package:uuid/uuid.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Mib3, Mib3Sub, Setting])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  static final AppDatabase instance = AppDatabase._internal();

  factory AppDatabase() => instance;

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
          SettingCompanion.insert(id: 'font', content: 'OpenSans'),
          SettingCompanion.insert(id: 'font_size', content: '14'),
          SettingCompanion.insert(id: 'view_font_size', content: '16'),
          SettingCompanion.insert(id: 'line_size', content: '10'),
        ]);
      });
    },
  );


// ====================
// mib3_sub
// ====================

  // Future<List<Mib3SubData>> getSubsAll(String masterId) {
  //   return (select(mib3Sub)..where((t) => t.masterId.equals(masterId))).get();
  // }
  //
  // Stream<List<Mib3SubData>> watchSuball(String masterId) {
  //   return (select(mib3Sub)..where((t) => t.masterId.equals(masterId))).watch();
  // }

  Future<List<Mib3SubData>> watchSubsAll() => select(mib3Sub).get();
  Stream<List<Mib3SubData>> watchSubAll() => select(mib3Sub).watch();

  Stream<List<MibWithLastSubDate>> watchJinWithLastSubDate() {
    return (select(mib3)
      ..where((t) => t.tb.equals('진행')))
        .watch()
        .asyncMap((memos) async {
      final list = <MibWithLastSubDate>[];

      for (final memo in memos) {
        final lastSub = await (select(mib3Sub)
          ..where((t) => t.masterId.equals(memo.id))
          ..orderBy([
                (t) => OrderingTerm(
              expression: t.sdate,
              mode: OrderingMode.desc,
            )
          ])
          ..limit(1))
            .getSingleOrNull();

        list.add(
          MibWithLastSubDate(
            memo: memo,               // mib3의 모든 컬럼
            lastSubDate: lastSub?.sdate, // 마지막 sub 날짜
          ),
        );
      }

      return list;
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
