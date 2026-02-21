import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

import 'app_database.dart';

class ThemeController extends GetxController {
  final fontFamily = 'OpenSans-Medium'.obs;
  final themeMode = ThemeMode.system.obs;

  void setFont(String font) {
    fontFamily.value = font;
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
  }

  ThemeData get lightTheme =>
      ThemeData(brightness: Brightness.light, fontFamily: fontFamily.value);

  ThemeData get darkTheme =>
      ThemeData(brightness: Brightness.dark, fontFamily: fontFamily.value);
}

/// =====================
/// Offline Sync
/// =====================
enum SyncAction { add, update, delete }

ThemeMode _parseTheme(String v) {
  switch (v) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}



class Mib3Decoded {
  final Mib3Data raw;
  final Map<String, dynamic> content;

  Mib3Decoded({
    required this.raw,
    required this.content,
  });
}


class MibProgressDecoded {
  final Mib3Data raw;
  final Map<String, dynamic> content;
  final String? lastSubDate;

  MibProgressDecoded({
    required this.raw,
    required this.content,
    required this.lastSubDate,
  });
}


/// =====================
/// Controller
/// =====================
class Mib3Controller extends GetxController {
  // =====================
  // DB / Firebase
  // =====================
  final AppDatabase db;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? uid; // ❗ nullable

  // =====================
  // Setting
  // =====================
  String setting_font = 'OpenSans-Medium';
  String setting_theme = 'system';
  int setting_font_size = 14;
  int setting_view_font_size = 18;
  int setting_line_size = 10;

  var temp_data = <String, dynamic>{'id': 'new'};
  var sub_temp_data = <String, dynamic>{'id': 'new'};

  Mib3Controller(this.db);

  final Map<String, Map<String, dynamic>> _decodeCache = {};

  Map<String, dynamic> decode(Mib3Data e) {
    final key = '${e.id}_${e.content.hashCode}';

    return _decodeCache.putIfAbsent(
      key,
          () => jsonDecode(e.content) as Map<String, dynamic>,
    );
  }

  Stream<List<Mib3Decoded>> watchMemo({
    required String wanFlag,
    required String jongFlag,
    required bool sortById,
    required String searchText,
  }) {
    final query = db.select(db.mib3)
      ..where((tbl) => tbl.tb.equals('메모') & tbl.wan.equals(wanFlag));

    return query.watch().map((rows) {
      // 1️⃣ 필터
      final filtered = rows.where((item) {
        final d = decode(item); // ✅ 공용 캐시 사용

        if (d['jong'].toString() != jongFlag) return false;

        if (searchText.isNotEmpty &&
            !d['content1']
                .toString()
                .toLowerCase()
                .contains(searchText.toLowerCase())) {
          return false;
        }

        return true;
      });

      // 2️⃣ DTO 변환
      final result = filtered
          .map(
            (item) => Mib3Decoded(
          raw: item,
          content: decode(item), // ✅ 재사용
        ),
      )
          .toList();

      // 3️⃣ 정렬
      result.sort((a, b) => sortById
          ? b.raw.id.compareTo(a.raw.id)
          : a.content['content1']
          .toString()
          .compareTo(b.content['content1'].toString()));

      return result;
    });
  }

  Stream<List<Mib3Decoded>> watchDiary({
    required String wanFlag,
    required bool sortByDateDesc,
    String searchText = '',
  }) {
    final query = db.select(db.mib3)
      ..where((tbl) => tbl.tb.equals('일기') & tbl.wan.equals(wanFlag));

    return query.watch().map((rows) {
      // 1️⃣ 필터
      final filtered = rows.where((item) {
        final d = decode(item); // ✅ 공용 캐시

        if (searchText.isNotEmpty &&
            !d['content1']
                .toString()
                .toLowerCase()
                .contains(searchText.toLowerCase())) {
          return false;
        }

        return true;
      });

      // 2️⃣ DTO 변환
      final result = filtered
          .map(
            (item) => Mib3Decoded(
          raw: item,
          content: decode(item), // ✅ 재사용
        ),
      )
          .toList();

      // 3️⃣ 정렬
      result.sort(
        sortByDateDesc
            ? (a, b) => b.content['s_date']
            .toString()
            .compareTo(a.content['s_date'].toString())
            : (a, b) => a.content['content1']
            .toString()
            .compareTo(b.content['content1'].toString()),
      );

      return result;
    });
  }

  Stream<List<Mib3Decoded>> watchTodo({
    required String wanFlag,
    required bool sortByDate,
    String dateLimit = '',
  }) {
    final query = db.select(db.mib3)
      ..where((tbl) => tbl.tb.equals('할일') & tbl.wan.equals(wanFlag));

    return query.watch().map((rows) {
      // 1️⃣ 필터
      var filtered = rows.where((item) {
        final d = decode(item); // 🔥 공용 캐시 사용

        if (dateLimit.isNotEmpty) {
          final limit = dateLimit.substring(0, 10);
          if (d['s_date'].toString().compareTo(limit) > 0) {
            return false;
          }
        }

        return true;
      });

      // 2️⃣ DTO 변환
      final result = filtered
          .map((item) => Mib3Decoded(
        raw: item,
        content: decode(item),
      ))
          .toList();

      // 3️⃣ 정렬
      result.sort(
        sortByDate
            ? (a, b) =>
            a.content['s_date'].compareTo(b.content['s_date'])
            : (a, b) =>
            a.content['content1']
                .toString()
                .compareTo(b.content['content1'].toString()),
      );

      return result;
    });
  }


  Stream<List<MibProgressDecoded>> watchProgress({
    required String wanFlag,
    required bool sortByContent,
  }) {
    final query = db.customSelect(
      '''
    SELECT m.*, MAX(s.sdate) AS last_sub_date
    FROM mib3 m
    LEFT JOIN mib3_sub s ON s.master_id = m.id
    WHERE m.tb = '진행' AND m.wan = ?
    GROUP BY m.id
    ''',
      variables: [drift.Variable(wanFlag)],
      readsFrom: {db.mib3, db.mib3Sub},
    );

    return query.watch().map((rows) {
      // ✅ Stream 1회 방출당 공용 캐시
      final Map<String, Map<String, dynamic>> cache = {};

      Map<String, dynamic> decode(Mib3Data m) {
        return cache.putIfAbsent(m.id, () => jsonDecode(m.content));
      }

      // 1️⃣ DTO 변환
      final list = rows.map((row) {
        final raw = db.mib3.map(row.data);
        return MibProgressDecoded(
          raw: raw,
          content: decode(raw),
          lastSubDate: row.read<String?>('last_sub_date'),
        );
      }).toList();

      // 2️⃣ 정렬
      list.sort((a, b) => sortByContent
          ? a.content['content1']
          .toString()
          .compareTo(b.content['content1'].toString())
          : b.raw.id.compareTo(a.raw.id));

      return list;
    });
  }


  Future<String> buildSubContent(String memoId) async {
    final list = await db.getSubsByMaster(memoId);

    // 🔥 함수 호출 단위 지역 캐시
    final Map<String, Map<String, dynamic>> cache = {};

    Map<String, dynamic> decode(Mib3SubData row) {
      return cache.putIfAbsent(
        row.id,
            () => jsonDecode(row.content),
      );
    }

    final buffer = StringBuffer();

    for (final s in list) {
      final row = decode(s);

      buffer.writeln(
        "${s.sdate}(${get_date_yo(s.sdate)})",
      );
      buffer.writeln(row['content1']);
      buffer.writeln(row['content2']);
      buffer.writeln();
    }

    return buffer.toString();
  }

  // =====================
  // Init
  // =====================
  @override
  void onInit() {
    super.onInit();
    loadSettings();

    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        uid = null;
        print('🔓 로그아웃 상태');
        await _resetAll(); // ← 여기
      } else {
        uid = user.uid;
        print('🔐 로그인됨: $uid');

        _syncMib3FromFirebase();
        _syncMib3SubFromFirebase();
      }
    });
  }

  Future<void> _resetAll() async {
    print('🧹 RESET ALL START');
    // 1️⃣ 로컬 DB 전체 삭제
    await db.clearAll();
    // ⬆️ AppDatabase에 clearAll() 함수 필요 (아래 참고)

    temp_data = <String, dynamic>{'id': 'new'};
    sub_temp_data = <String, dynamic>{'id': 'new'};

    print('🧹 RESET ALL DONE');
  }

  // =====================
  // Setting
  // =====================
  Future<void> loadSettings() async {
    final themeCtrl = Get.find<ThemeController>();
    final list = await db.getAllSettings();
    for (final s in list) {
      switch (s.id) {
        case 'theme': // ⭐ 추가
          setting_theme = s.content;
          themeCtrl.setThemeMode(_parseTheme(s.content));

          break;
        case 'font':
          setting_font = s.content;
          themeCtrl.setFont(s.content);
          break;
        case 'font_size':
          setting_font_size = int.tryParse(s.content) ?? 1;
          break;
        case 'view_font_size':
          setting_view_font_size = int.tryParse(s.content) ?? 1;
          break;
        case 'line_size':
          setting_line_size = int.tryParse(s.content) ?? 1;
          break;
      }
    }
  }

  Future<void> updateSetting(String id, String value) async {
    await db.setSetting(id, value);

    switch (id) {
      case 'theme':
        setting_theme = value;
        break;
      case 'font':
        setting_font = value;
        break;
      case 'font_size':
        setting_font_size = int.tryParse(value) ?? setting_font_size;
        break;
      case 'view_font_size':
        setting_view_font_size = int.tryParse(value) ?? setting_view_font_size;
        break;
      case 'line_size':
        setting_line_size = int.tryParse(value) ?? setting_line_size;
        break;
    }
    update();
  }

  // =====================
  // Firebase → Local
  // =====================
  void _syncMib3FromFirebase() {
    if (uid == null) return;

    firestore
        .collection('users')
        .doc(uid)
        .collection('mib3')
        .snapshots()
        .listen((snap) async {
          for (final c in snap.docChanges) {
            final d = c.doc.data();
            if (d == null) continue;

            final row = Mib3Companion(
              id: drift.Value(c.doc.id),
              tb: drift.Value(d['tb']),
              wan: drift.Value(d['wan']),
              content: drift.Value(d['content']),
            );

            if (c.type == DocumentChangeType.removed) {
              await db.deleteRow(c.doc.id);
            } else {
              await db.insertRow(row);
            }
          }
        });
  }

  void _syncMib3SubFromFirebase() {
    if (uid == null) return;

    firestore
        .collection('users')
        .doc(uid)
        .collection('mib3_sub')
        .snapshots()
        .listen((snap) async {
          for (final c in snap.docChanges) {
            final d = c.doc.data();
            if (d == null) continue;

            final row = Mib3SubCompanion(
              id: drift.Value(c.doc.id),
              masterId: drift.Value(d['masterId']),
              sdate: drift.Value(d['sdate']),
              content: drift.Value(d['content']),
            );

            if (c.type == DocumentChangeType.removed) {
              await db.deleteSub(c.doc.id);
            } else {
              await db.insertSub(row);
            }
          }
        });
  }

  // =====================
  // mib3 CRUD ⭐ FIXED
  // =====================
  Future<void> addItem(String tb, String wan, String content) async {
    if (uid == null) {
      print('❌ addItem 실패: 로그인 안됨');
      return;
    }

    final id = const Uuid().v4();

    // 1️⃣ 로컬 DB
    await db.insertRow(
      Mib3Companion.insert(id: id, tb: tb, wan: wan, content: content),
    );

    // 2️⃣ Firebase

      await firestore
          .collection('users')
          .doc(uid)
          .collection('mib3')
          .doc(id)
          .set({'tb': tb, 'wan': wan, 'content': content});

  }

  Future<void> updateItem(
    String id,
    String tb,
    String wan,
    String content,
  ) async {
    if (uid == null) {
      print('❌ updateItem 실패: 로그인 안됨');
      return;
    }

    // 1️⃣ 로컬 DB 업데이트
    await db.insertRow(
      Mib3Companion(
        id: drift.Value(id),
        tb: drift.Value(tb),
        wan: drift.Value(wan),
        content: drift.Value(content),
      ),
    );

    // 2️⃣ Firebase 업데이트
      await firestore
          .collection('users')
          .doc(uid)
          .collection('mib3')
          .doc(id)
          .update({'tb': tb, 'wan': wan, 'content': content});

  }

  Future<void> removeItem(String id) async {
    if (uid == null) return;

    // 1️⃣ 로컬 DB 삭제
    await db.deleteRow(id);
    await db.deleteSubsByMaster(id);

    // 2️⃣ Firebase 삭제
      await firestore
          .collection('users')
          .doc(uid)
          .collection('mib3')
          .doc(id)
          .delete();

      // 하위 sub 삭제
      final qs = await firestore
          .collection('users')
          .doc(uid)
          .collection('mib3_sub')
          .where('masterId', isEqualTo: id)
          .get();

      for (final d in qs.docs) {
        await d.reference.delete();
      }
  }

  // =====================
  // mib3_sub CRUD
  // =====================
  Future<void> addSub(String masterId, String sdate, String content) async {
    if (uid == null) return;

    final id = const Uuid().v4();

    await db.insertSub(
      Mib3SubCompanion.insert(
        id: id,
        masterId: masterId,
        sdate: sdate,
        content: content,
      ),
    );

    await firestore
        .collection('users')
        .doc(uid)
        .collection('mib3_sub')
        .doc(id)
        .set({'masterId': masterId, 'sdate': sdate, 'content': content});
  }

  Future<void> updateSub(String id, String sdate, String content) async {
    if (uid == null) return;

    // 1️⃣ 로컬 DB
    await db.updateSub(id: id, sdate: sdate, content: content);

    // 2️⃣ Firebase
      final data = <String, dynamic>{};
      if (sdate != null) data['sdate'] = sdate;
      if (content != null) data['content'] = content;

      await firestore
          .collection('users')
          .doc(uid)
          .collection('mib3_sub')
          .doc(id)
          .update(data);
  }

  Future<void> removeSub(String id) async {
    if (uid == null) return;

    // 1️⃣ 로컬 DB
    await db.deleteSub(id);

    // 2️⃣ Firebase
      await firestore
          .collection('users')
          .doc(uid)
          .collection('mib3_sub')
          .doc(id)
          .delete();
  }

  Future<void> removeByMasterSub(String masterId) async {
    if (uid == null) return;

    // 1️⃣ 로컬 DB – 해당 master의 sub 전부 삭제
    await db.deleteSubsByMaster(masterId);

    // 2️⃣ Firebase – 해당 masterId 가진 sub 전부 삭제
      final qs = await firestore
          .collection('users')
          .doc(uid)
          .collection('mib3_sub')
          .where('masterId', isEqualTo: masterId)
          .get();

      for (final doc in qs.docs) {
        await doc.reference.delete();
      }
  }
}

/// =====================
/// Utils
/// =====================
void show_toast(String msg, context) {
  showToast(msg, context: context, position: StyledToastPosition.top);
}

String get_date_yo(String pDate) {
  if (pDate.length < 10) return '';
  return DateFormat('E', 'ko_KR').format(DateTime.parse(pDate)); // 월
}

int get_date_term2(String pDate) {
  if (pDate.length < 10) return 0;

  final todayStr =
  DateTime.now().toIso8601String().substring(0, 10);

  final today = DateTime.parse(todayStr);
  final target = DateTime.parse(pDate.substring(0, 10));

  return target.difference(today).inDays*-1;
}

int get_term_day(String date_1, String date_2) {
  var date_now = DateTime(
    int.parse(date_1.substring(0, 4)),
    int.parse(date_1.substring(5, 7)),
    int.parse(date_1.substring(8, 10)),
  );
  var date_last = DateTime(
    int.parse(date_2.substring(0, 4)),
    int.parse(date_2.substring(5, 7)),
    int.parse(date_2.substring(8, 10)),
  );

  return date_now.difference(date_last).inDays;
}
