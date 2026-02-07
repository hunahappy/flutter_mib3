import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'app_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' as drift;
import 'db_helper.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

/// 오프라인 큐 상태
enum SyncAction { add, update, delete }

class SyncQueueItem {
  final String id;
  final SyncAction action;
  final Mib3Companion? row;

  SyncQueueItem({required this.id, required this.action, this.row});
}

class Mib3Controller extends GetxController {
  var setting_font = '';
  int setting_font_size = 1;
  int setting_view_font_size = 1;
  int setting_line_size = 1;
  var temp_data = <String, dynamic>{"id": "new",};

  final AppDatabase db;
  final items = <Mib3Data>[].obs;
  final firestore = FirebaseFirestore.instance;

  // 오프라인 큐
  final _syncQueue = <SyncQueueItem>[];

  Mib3Controller(this.db) {
    // Drift 로컬 DB 감시
    db.watchAll().listen((rows) {
      items.value = rows;
    });
    // Firebase 실시간 감시
    firestore.collection('mib3').snapshots().listen((snapshot) async {
      for (var change in snapshot.docChanges) {
        final data = change.doc.data();
        if (data == null) continue;

        final row = Mib3Companion(
          id: drift.Value(change.doc.id),
          tb: drift.Value(data['tb'] ?? ''),
          wan: drift.Value(data['wan'] ?? ''),
          content: drift.Value(data['content'] ?? ''),
        );

        switch (change.type) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            await db.insertRow(row); // 중복 시 대체
            break;
          case DocumentChangeType.removed:
            await db.deleteRow(change.doc.id);
            break;
        }
      }
    });
  }

  /// 새로운 아이템 추가
  Future<void> addItem(String tb, String wan, String content) async {
    final id = const Uuid().v4();
    final row = Mib3Companion.insert(
      id: id,
      tb: tb,
      wan: wan,
      content: content,
    );

    // 로컬 DB에 먼저 삽입
    await db.insertRow(row);

    try {
      // 네트워크 연결 시 Firebase에 추가
      await firestore.collection('mib3').doc(id).set({
        'tb': tb,
        'wan': wan,
        'content': content,
      });
    } catch (_) {
      // 실패 시 오프라인 큐에 추가
      _syncQueue.add(SyncQueueItem(id: id, action: SyncAction.add, row: row));
    }
  }

  /// 아이템 삭제
  Future<void> removeItem(String id) async {
    await db.deleteRow(id);

    try {
      await firestore.collection('mib3').doc(id).delete();
    } catch (_) {
      _syncQueue.add(SyncQueueItem(id: id, action: SyncAction.delete));
    }
  }

  /// 아이템 수정
  Future<void> updateItem(String id, String tb, String wan, String content) async {
    final row = Mib3Companion(
      id: drift.Value(id),
      tb: drift.Value(tb),
      wan: drift.Value(wan),
      content: drift.Value(content),
    );

    await db.insertRow(row); // Drift에서는 insertOrReplace 사용

    try {
      await firestore.collection('mib3').doc(id).set({
        'tb': tb,
        'wan': wan,
        'content': content,
      });
    } catch (_) {
      _syncQueue.add(SyncQueueItem(id: id, action: SyncAction.update, row: row));
    }
  }

  /// 오프라인 큐 동기화
  Future<void> syncFromQueue() async {
    if (_syncQueue.isEmpty) return;

    final List<SyncQueueItem> success = [];

    for (var item in _syncQueue) {
      try {
        switch (item.action) {
          case SyncAction.add:
          case SyncAction.update:
            if (item.row != null) {
              await firestore.collection('mib3').doc(item.id).set({
                'tb': item.row!.tb.value,
                'wan': item.row!.wan.value,
                'content': item.row!.content.value,
              });
            }
            break;
          case SyncAction.delete:
            await firestore.collection('mib3').doc(item.id).delete();
            break;
        }
        success.add(item);
      } catch (_) {
        // 실패한 건 그대로 큐에 남김
      }
    }

    // 성공한 작업 큐에서 제거
    _syncQueue.removeWhere((item) => success.contains(item));
  }
}

void show_toast(String message, context) {
  showToast(message, context: context, position: StyledToastPosition.top);
}

String get_date_yo(String pDate) {
  var str_return = "";
  if (pDate.length > 9) {
    str_return =
        DateFormat.E().format(DateTime(int.parse(pDate.substring(0, 4)), int.parse(pDate.substring(5, 7)), int.parse(pDate.substring(8, 10))));
  }

  return str_return;
}

String get_date_term2(String pDate) {
  var str_return = "";
  if (pDate.length > 9) {
    str_return = DateTime(int.parse(pDate.substring(0, 4)), int.parse(pDate.substring(5, 7)), int.parse(pDate.substring(8, 10)))
        .difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
        .inDays
        .toString();
  }

  return str_return;
}



