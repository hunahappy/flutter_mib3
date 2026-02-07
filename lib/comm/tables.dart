import 'package:drift/drift.dart';

class Mib3 extends Table {
  TextColumn get id => text()();
  TextColumn get tb => text()();      // non-nullable
  TextColumn get wan => text()();     // non-nullable
  TextColumn get content => text()(); // non-nullable

  @override
  Set<Column> get primaryKey => {id};
}

class Setting extends Table {
  TextColumn get id => text()();       // primary key
  TextColumn get content => text()();  // 값
  @override
  Set<Column> get primaryKey => {id};
}