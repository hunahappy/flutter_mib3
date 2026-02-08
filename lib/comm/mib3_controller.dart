import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'app_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

/// 오프라인 큐 상태
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

class Mib3Controller extends GetxController {
  // =====================
  // Setting
  // =====================
  var setting_font = '';
  int setting_font_size = 1;
  int setting_view_font_size = 1;
  int setting_line_size = 1;

  var temp_data = <String, dynamic>{'id': 'new'};
  var sub_temp_data = <String, dynamic>{'id': 'new'};

  // =====================
  // DB / Firebase
  // =====================
  final AppDatabase db;
  final firestore = FirebaseFirestore.instance;

  // =====================
  // Observable
  // =====================
  final items = <Mib3Data>[].obs;
  final items_jin = <MibWithLastSubDate>[].obs;
  final subs = <Mib3SubData>[].obs;

  // Offline Queue
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
    _syncMib3FromFirebase();
    _syncMib3SubFromFirebase();
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

  // =====================
  // Local Watch
  // =====================
  void _watchLocal() {
    db.watchAll().listen((rows) => items.value = rows);
    db.watchSubAll().listen((rows) => subs.value = rows);
    db.watchJinWithLastSubDate().listen((rows) => items_jin.value = rows);
  }

  // =====================
  // Firebase → Local (mib3)
  // =====================
  void _syncMib3FromFirebase() {
    firestore.collection('mib3').snapshots().listen((snap) async {
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

  // =====================
  // Firebase → Local (mib3_sub)
  // =====================
  void _syncMib3SubFromFirebase() {
    firestore.collection('mib3_sub').snapshots().listen((snap) async {
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
  // mib3 CRUD
  // =====================
  Future<void> addItem(String tb, String wan, String content) async {
    final id = const Uuid().v4();

    await db.insertRow(Mib3Companion.insert(
      id: id,
      tb: tb,
      wan: wan,
      content: content,
    ));

    try {
      await firestore.collection('mib3').doc(id).set({
        'tb': tb,
        'wan': wan,
        'content': content,
      });
    } catch (_) {
      _syncQueue.add(SyncQueueItem(
        id: id,
        collection: 'mib3',
        action: SyncAction.add,
        data: {'tb': tb, 'wan': wan, 'content': content},
      ));
    }
  }

  Future<void> updateItem(String id, String tb, String wan, String content) async {
    await db.insertRow(Mib3Companion(
      id: drift.Value(id),
      tb: drift.Value(tb),
      wan: drift.Value(wan),
      content: drift.Value(content),
    ));

    try {
      await firestore.collection('mib3').doc(id).set({
        'tb': tb,
        'wan': wan,
        'content': content,
      });
    } catch (_) {
      _syncQueue.add(SyncQueueItem(
        id: id,
        collection: 'mib3',
        action: SyncAction.update,
        data: {'tb': tb, 'wan': wan, 'content': content},
      ));
    }
  }

  Future<void> removeItem(String id) async {
    await db.deleteRow(id);
    await db.deleteSubsByMaster(id);

    try {
      await firestore.collection('mib3').doc(id).delete();
      final qs = await firestore
          .collection('mib3_sub')
          .where('masterId', isEqualTo: id)
          .get();
      for (final d in qs.docs) {
        await d.reference.delete();
      }
    } catch (_) {
      _syncQueue.add(SyncQueueItem(
        id: id,
        collection: 'mib3',
        action: SyncAction.delete,
      ));
    }
  }

  // =====================
  // mib3_sub CRUD ⭐⭐⭐
  // =====================
  Future<void> addSub(String masterId, String sdate, String content) async {
    final id = const Uuid().v4();

    await db.insertSub(Mib3SubCompanion.insert(
      id: id,
      masterId: masterId,
      sdate: sdate,
      content: content,
    ));

    try {
      await firestore.collection('mib3_sub').doc(id).set({
        'masterId': masterId,
        'sdate': sdate,
        'content': content,
      });
    } catch (_) {
      _syncQueue.add(SyncQueueItem(
        id: id,
        collection: 'mib3_sub',
        action: SyncAction.add,
        data: {'masterId': masterId, 'sdate': sdate, 'content': content},
      ));
    }
  }

  Future<void> updateSub(
    String id,
    String? sdate,
    String? content,
  ) async {
    // 1️⃣ 로컬 Drift DB 업데이트
    await db.updateSub(
      id: id,
      sdate: sdate,
      content: content,
    );

    try {
      // 2️⃣ Firebase 업데이트
      final data = <String, dynamic>{};

      if (content != null) data['content'] = content;
      if (sdate != null) data['sdate'] = sdate;

      await firestore.collection('mib3_sub').doc(id).update(data);
    } catch (_) {
      // 3️⃣ 실패 시 오프라인 큐에 저장
      _syncQueue.add(
        SyncQueueItem(
          id: id,
          collection: 'mib3_sub',
          action: SyncAction.update,
          data: {
            if (content != null) 'content': content,
            if (sdate != null) 'sdate': sdate,
          },
        ),
      );
    }
  }

  Future<void> removeSub(String id) async {
    await db.deleteSub(id);

    try {
      await firestore.collection('mib3_sub').doc(id).delete();
    } catch (_) {
      _syncQueue.add(SyncQueueItem(
        id: id,
        collection: 'mib3_sub',
        action: SyncAction.delete,
      ));
    }
  }

  Future<void> removeByMasterSub(String id) async {
    await db.deleteSubsByMaster(id);

    try {
      await firestore.collection('mib3_sub').doc(id).delete();
    } catch (_) {
      _syncQueue.add(SyncQueueItem(
        id: id,
        collection: 'mib3_sub',
        action: SyncAction.delete,
      ));
    }
  }


  Future<void> updateSetting(String id, String value) async {
    await db.setSetting(id,value);

    // 👉 메모리 값도 같이 갱신 (즉시 UI 반영용)
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

    update(); // GetX 수동 갱신 (Obx 안 쓰는 위젯용)
  }

  // =====================
  // Offline Queue Sync
  // =====================
  Future<void> syncFromQueue() async {
    final success = <SyncQueueItem>[];

    for (final q in _syncQueue) {
      try {
        final ref = firestore.collection(q.collection).doc(q.id);

        switch (q.action) {
          case SyncAction.add:
          case SyncAction.update:
            await ref.set(q.data!, SetOptions(merge: true));
            break;
          case SyncAction.delete:
            await ref.delete();
            break;
        }
        success.add(q);
      } catch (_) {}
    }

    _syncQueue.removeWhere((e) => success.contains(e));
  }
}

// =====================
// Utils
// =====================
void show_toast(String msg, context) {
  showToast(msg,
      context: context, position: StyledToastPosition.top);
}

String get_date_yo(String pDate) {
  if (pDate.length < 10) return '';
  return DateFormat.E().format(DateTime.parse(pDate));
}

int get_date_term2(String pDate) {
  if (pDate.length < 10) return 0;
  return DateTime.parse(pDate)
      .difference(DateTime.now())
      .inDays * -1;
}

int get_term_day(String date_1, String date_2) {
  var date_now = DateTime(int.parse(date_1.substring(0, 4)), int.parse(date_1.substring(5, 7)), int.parse(date_1.substring(8, 10)));
  var date_last = DateTime(int.parse(date_2.substring(0, 4)), int.parse(date_2.substring(5, 7)), int.parse(date_2.substring(8, 10)));

  return date_now.difference(date_last).inDays;
}
