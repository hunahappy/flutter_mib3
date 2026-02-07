import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    if (kDebugMode) {
      print('📦 DB open');
    }

    _db = await openDatabase(
      join(await getDatabasesPath(), 'mib3.db'),
      version: 1,
      onCreate: (db, version) async {
        // 메인 테이블
        await db.execute('''
          CREATE TABLE mib3 (
            id TEXT PRIMARY KEY,
            tb TEXT,
            wan TEXT,
            content TEXT
          )
        ''');

        // 서브 테이블
        await db.execute('''
          CREATE TABLE mib3_sub (
            id TEXT PRIMARY KEY,
            master_id TEXT,
            sdate TEXT,
            content TEXT
          )
        ''');

        // 설정 테이블
        await db.execute('''
          CREATE TABLE setting (
            id TEXT PRIMARY KEY,
            content TEXT
          )
        ''');

        await db.insert('setting', {'id': 'font', 'content': 'OpenSans'});
        await db.insert('setting', {'id': 'font_size', 'content': '12'});
        await db.insert('setting', {'id': 'view_font_size', 'content': '15'});
        await db.insert('setting', {'id': 'line_size', 'content': '10'});
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (kDebugMode) {
          print('⬆️ DB upgrade $oldVersion → $newVersion');
        }
      },
    );

    return _db!;
  }

  // Future<List<Map<String, dynamic>>> getAll() async {
  //   final db = await database;
  //   return db.query('mib3', orderBy: 'id DESC');
  // }
  //
  // Future<void> insert(Map<String, dynamic> data) async {
  //   final db = await database;
  //   await db.insert(
  //     'memo',
  //     data,
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }
  //
  // Future<void> delete(String id) async {
  //   final db = await database;
  //   await db.delete('memo', where: 'id = ?', whereArgs: [id]);
  // }
  //
  // Future<List<Map<String, dynamic>>> selectRows(
  //     String pSqlText, List pSqlJo) async {
  //   final db = await database;
  //
  //   List<Map<String, dynamic>> rows = await db.rawQuery(pSqlText, pSqlJo);
  //
  //   return rows;
  // }

}