import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

import 'app_database.dart';

/// =====================
/// Offline Sync
/// =====================
enum SyncAction { add, update, delete }

class SyncQueueItem {
  final String id;
  final String collection;
  final SyncAction action;
  final Map<String, dynamic>? data;

  SyncQueueItem({
    required this.id,
    required this.collection,
    required this.action,
    this.data,
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
  String setting_font = '';
  int setting_font_size = 14;
  int setting_view_font_size = 18;
  int setting_line_size = 10;

  var temp_data = <String, dynamic>{'id': 'new'};
  var sub_temp_data = <String, dynamic>{'id': 'new'};
  // =====================
  // Observable
  // =====================
  final items = <Mib3Data>[].obs;
  final items_jin = <MibWithLastSubDate>[].obs;
  final subs = <Mib3SubData>[].obs;

  final _syncQueue = <SyncQueueItem>[];

  Mib3Controller(this.db);

  // =====================
  // Init
  // =====================
  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _watchLocal();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        uid = null;
        print('🔓 로그아웃 상태');
      } else {
        uid = user.uid;
        print('🔐 로그인됨: $uid');

        _syncMib3FromFirebase();
        _syncMib3SubFromFirebase();
      }
    });
  }

  // =====================
  // Setting
  // =====================
  Future<void> _loadSettings() async {
    final list = await db.getAllSettings();
    for (final s in list) {
      switch (s.id) {
        case 'font':
          setting_font = s.content;
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
  // Local Watch
  // =====================
  void _watchLocal() {
    db.watchAll().listen((rows) => items.value = rows);
    db.watchSubAll().listen((rows) => subs.value = rows);
    db.watchJinWithLastSubDate().listen((rows) => items_jin.value = rows);
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
      Mib3Companion.insert(
        id: id,
        tb: tb,
        wan: wan,
        content: content,
      ),
    );

    // 2️⃣ Firebase
    try {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('mib3')
          .doc(id)
          .set({
        'tb': tb,
        'wan': wan,
        'content': content,
      });
    } catch (e) {
      _syncQueue.add(
        SyncQueueItem(
          id: id,
          collection: 'mib3',
          action: SyncAction.add,
          data: {
            'tb': tb,
            'wan': wan,
            'content': content,
          },
        ),
      );
    }
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
    try {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('mib3')
          .doc(id)
          .update({
        'tb': tb,
        'wan': wan,
        'content': content,
      });
    } catch (_) {
      // 3️⃣ 실패 시 오프라인 큐
      _syncQueue.add(
        SyncQueueItem(
          id: id,
          collection: 'mib3',
          action: SyncAction.update,
          data: {
            'tb': tb,
            'wan': wan,
            'content': content,
          },
        ),
      );
    }
  }

  Future<void> removeItem(String id) async {
    if (uid == null) return;

    // 1️⃣ 로컬 DB 삭제
    await db.deleteRow(id);
    await db.deleteSubsByMaster(id);

    // 2️⃣ Firebase 삭제
    try {
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
    } catch (_) {
      _syncQueue.add(
        SyncQueueItem(
          id: id,
          collection: 'mib3',
          action: SyncAction.delete,
        ),
      );
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
        .set({
      'masterId': masterId,
      'sdate': sdate,
      'content': content,
    });
  }

  Future<void> updateSub(
      String id,
        String sdate,
        String content,
      ) async {
    if (uid == null) return;

    // 1️⃣ 로컬 DB
    await db.updateSub(
      id: id,
      sdate: sdate,
      content: content,
    );

    // 2️⃣ Firebase
    try {
      final data = <String, dynamic>{};
      if (sdate != null) data['sdate'] = sdate;
      if (content != null) data['content'] = content;

      await firestore
          .collection('users')
          .doc(uid)
          .collection('mib3_sub')
          .doc(id)
          .update(data);
    } catch (_) {
      _syncQueue.add(
        SyncQueueItem(
          id: id,
          collection: 'mib3_sub',
          action: SyncAction.update,
          data: {
            if (sdate != null) 'sdate': sdate,
            if (content != null) 'content': content,
          },
        ),
      );
    }
  }

  Future<void> removeSub(String id) async {
    if (uid == null) return;

    // 1️⃣ 로컬 DB
    await db.deleteSub(id);

    // 2️⃣ Firebase
    try {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('mib3_sub')
          .doc(id)
          .delete();
    } catch (_) {
      _syncQueue.add(
        SyncQueueItem(
          id: id,
          collection: 'mib3_sub',
          action: SyncAction.delete,
        ),
      );
    }
  }

  Future<void> removeByMasterSub(String masterId) async {
    if (uid == null) return;

    // 1️⃣ 로컬 DB – 해당 master의 sub 전부 삭제
    await db.deleteSubsByMaster(masterId);

    // 2️⃣ Firebase – 해당 masterId 가진 sub 전부 삭제
    try {
      final qs = await firestore
          .collection('users')
          .doc(uid)
          .collection('mib3_sub')
          .where('masterId', isEqualTo: masterId)
          .get();

      for (final doc in qs.docs) {
        await doc.reference.delete();
      }
    } catch (_) {
      // 3️⃣ 실패 시 오프라인 큐
      _syncQueue.add(
        SyncQueueItem(
          id: masterId,
          collection: 'mib3_sub',
          action: SyncAction.delete,
        ),
      );
    }
  }
}

/// =====================
/// Utils
/// =====================
void show_toast(String msg, context) {
  showToast(msg,
      context: context, position: StyledToastPosition.top);
}

String get_date_yo(String pDate) {
  if (pDate.length < 10) return '';
  return DateFormat('E', 'ko_KR').format(DateTime.parse(pDate)); // 월
}

int get_date_term2(String pDate) {
  if (pDate.length < 10) return 0;
  return DateTime.parse(pDate)
      .difference(DateTime.now())
      .inDays *
      -1;
}

int get_term_day(String date_1, String date_2) {
  var date_now = DateTime(int.parse(date_1.substring(0, 4)), int.parse(date_1.substring(5, 7)), int.parse(date_1.substring(8, 10)));
  var date_last = DateTime(int.parse(date_2.substring(0, 4)), int.parse(date_2.substring(5, 7)), int.parse(date_2.substring(8, 10)));

  return date_now.difference(date_last).inDays;
}