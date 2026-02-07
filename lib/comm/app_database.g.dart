// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $Mib3Table extends Mib3 with TableInfo<$Mib3Table, Mib3Data> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $Mib3Table(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tbMeta = const VerificationMeta('tb');
  @override
  late final GeneratedColumn<String> tb = GeneratedColumn<String>(
    'tb',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wanMeta = const VerificationMeta('wan');
  @override
  late final GeneratedColumn<String> wan = GeneratedColumn<String>(
    'wan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, tb, wan, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mib3';
  @override
  VerificationContext validateIntegrity(
    Insertable<Mib3Data> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tb')) {
      context.handle(_tbMeta, tb.isAcceptableOrUnknown(data['tb']!, _tbMeta));
    } else if (isInserting) {
      context.missing(_tbMeta);
    }
    if (data.containsKey('wan')) {
      context.handle(
        _wanMeta,
        wan.isAcceptableOrUnknown(data['wan']!, _wanMeta),
      );
    } else if (isInserting) {
      context.missing(_wanMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Mib3Data map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Mib3Data(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tb: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tb'],
      )!,
      wan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wan'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
    );
  }

  @override
  $Mib3Table createAlias(String alias) {
    return $Mib3Table(attachedDatabase, alias);
  }
}

class Mib3Data extends DataClass implements Insertable<Mib3Data> {
  final String id;
  final String tb;
  final String wan;
  final String content;
  const Mib3Data({
    required this.id,
    required this.tb,
    required this.wan,
    required this.content,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tb'] = Variable<String>(tb);
    map['wan'] = Variable<String>(wan);
    map['content'] = Variable<String>(content);
    return map;
  }

  Mib3Companion toCompanion(bool nullToAbsent) {
    return Mib3Companion(
      id: Value(id),
      tb: Value(tb),
      wan: Value(wan),
      content: Value(content),
    );
  }

  factory Mib3Data.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Mib3Data(
      id: serializer.fromJson<String>(json['id']),
      tb: serializer.fromJson<String>(json['tb']),
      wan: serializer.fromJson<String>(json['wan']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tb': serializer.toJson<String>(tb),
      'wan': serializer.toJson<String>(wan),
      'content': serializer.toJson<String>(content),
    };
  }

  Mib3Data copyWith({String? id, String? tb, String? wan, String? content}) =>
      Mib3Data(
        id: id ?? this.id,
        tb: tb ?? this.tb,
        wan: wan ?? this.wan,
        content: content ?? this.content,
      );
  Mib3Data copyWithCompanion(Mib3Companion data) {
    return Mib3Data(
      id: data.id.present ? data.id.value : this.id,
      tb: data.tb.present ? data.tb.value : this.tb,
      wan: data.wan.present ? data.wan.value : this.wan,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Mib3Data(')
          ..write('id: $id, ')
          ..write('tb: $tb, ')
          ..write('wan: $wan, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tb, wan, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mib3Data &&
          other.id == this.id &&
          other.tb == this.tb &&
          other.wan == this.wan &&
          other.content == this.content);
}

class Mib3Companion extends UpdateCompanion<Mib3Data> {
  final Value<String> id;
  final Value<String> tb;
  final Value<String> wan;
  final Value<String> content;
  final Value<int> rowid;
  const Mib3Companion({
    this.id = const Value.absent(),
    this.tb = const Value.absent(),
    this.wan = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  Mib3Companion.insert({
    required String id,
    required String tb,
    required String wan,
    required String content,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tb = Value(tb),
       wan = Value(wan),
       content = Value(content);
  static Insertable<Mib3Data> custom({
    Expression<String>? id,
    Expression<String>? tb,
    Expression<String>? wan,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tb != null) 'tb': tb,
      if (wan != null) 'wan': wan,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  Mib3Companion copyWith({
    Value<String>? id,
    Value<String>? tb,
    Value<String>? wan,
    Value<String>? content,
    Value<int>? rowid,
  }) {
    return Mib3Companion(
      id: id ?? this.id,
      tb: tb ?? this.tb,
      wan: wan ?? this.wan,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tb.present) {
      map['tb'] = Variable<String>(tb.value);
    }
    if (wan.present) {
      map['wan'] = Variable<String>(wan.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('Mib3Companion(')
          ..write('id: $id, ')
          ..write('tb: $tb, ')
          ..write('wan: $wan, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $Mib3SubTable extends Mib3Sub with TableInfo<$Mib3SubTable, Mib3SubData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $Mib3SubTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _masterIdMeta = const VerificationMeta(
    'masterId',
  );
  @override
  late final GeneratedColumn<String> masterId = GeneratedColumn<String>(
    'master_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sdateMeta = const VerificationMeta('sdate');
  @override
  late final GeneratedColumn<String> sdate = GeneratedColumn<String>(
    'sdate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, masterId, sdate, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mib3_sub';
  @override
  VerificationContext validateIntegrity(
    Insertable<Mib3SubData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('master_id')) {
      context.handle(
        _masterIdMeta,
        masterId.isAcceptableOrUnknown(data['master_id']!, _masterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_masterIdMeta);
    }
    if (data.containsKey('sdate')) {
      context.handle(
        _sdateMeta,
        sdate.isAcceptableOrUnknown(data['sdate']!, _sdateMeta),
      );
    } else if (isInserting) {
      context.missing(_sdateMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Mib3SubData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Mib3SubData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      masterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}master_id'],
      )!,
      sdate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sdate'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
    );
  }

  @override
  $Mib3SubTable createAlias(String alias) {
    return $Mib3SubTable(attachedDatabase, alias);
  }
}

class Mib3SubData extends DataClass implements Insertable<Mib3SubData> {
  final String id;
  final String masterId;
  final String sdate;
  final String content;
  const Mib3SubData({
    required this.id,
    required this.masterId,
    required this.sdate,
    required this.content,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['master_id'] = Variable<String>(masterId);
    map['sdate'] = Variable<String>(sdate);
    map['content'] = Variable<String>(content);
    return map;
  }

  Mib3SubCompanion toCompanion(bool nullToAbsent) {
    return Mib3SubCompanion(
      id: Value(id),
      masterId: Value(masterId),
      sdate: Value(sdate),
      content: Value(content),
    );
  }

  factory Mib3SubData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Mib3SubData(
      id: serializer.fromJson<String>(json['id']),
      masterId: serializer.fromJson<String>(json['masterId']),
      sdate: serializer.fromJson<String>(json['sdate']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'masterId': serializer.toJson<String>(masterId),
      'sdate': serializer.toJson<String>(sdate),
      'content': serializer.toJson<String>(content),
    };
  }

  Mib3SubData copyWith({
    String? id,
    String? masterId,
    String? sdate,
    String? content,
  }) => Mib3SubData(
    id: id ?? this.id,
    masterId: masterId ?? this.masterId,
    sdate: sdate ?? this.sdate,
    content: content ?? this.content,
  );
  Mib3SubData copyWithCompanion(Mib3SubCompanion data) {
    return Mib3SubData(
      id: data.id.present ? data.id.value : this.id,
      masterId: data.masterId.present ? data.masterId.value : this.masterId,
      sdate: data.sdate.present ? data.sdate.value : this.sdate,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Mib3SubData(')
          ..write('id: $id, ')
          ..write('masterId: $masterId, ')
          ..write('sdate: $sdate, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, masterId, sdate, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mib3SubData &&
          other.id == this.id &&
          other.masterId == this.masterId &&
          other.sdate == this.sdate &&
          other.content == this.content);
}

class Mib3SubCompanion extends UpdateCompanion<Mib3SubData> {
  final Value<String> id;
  final Value<String> masterId;
  final Value<String> sdate;
  final Value<String> content;
  final Value<int> rowid;
  const Mib3SubCompanion({
    this.id = const Value.absent(),
    this.masterId = const Value.absent(),
    this.sdate = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  Mib3SubCompanion.insert({
    required String id,
    required String masterId,
    required String sdate,
    required String content,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       masterId = Value(masterId),
       sdate = Value(sdate),
       content = Value(content);
  static Insertable<Mib3SubData> custom({
    Expression<String>? id,
    Expression<String>? masterId,
    Expression<String>? sdate,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (masterId != null) 'master_id': masterId,
      if (sdate != null) 'sdate': sdate,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  Mib3SubCompanion copyWith({
    Value<String>? id,
    Value<String>? masterId,
    Value<String>? sdate,
    Value<String>? content,
    Value<int>? rowid,
  }) {
    return Mib3SubCompanion(
      id: id ?? this.id,
      masterId: masterId ?? this.masterId,
      sdate: sdate ?? this.sdate,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (masterId.present) {
      map['master_id'] = Variable<String>(masterId.value);
    }
    if (sdate.present) {
      map['sdate'] = Variable<String>(sdate.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('Mib3SubCompanion(')
          ..write('id: $id, ')
          ..write('masterId: $masterId, ')
          ..write('sdate: $sdate, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingTable extends Setting with TableInfo<$SettingTable, SettingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
    );
  }

  @override
  $SettingTable createAlias(String alias) {
    return $SettingTable(attachedDatabase, alias);
  }
}

class SettingData extends DataClass implements Insertable<SettingData> {
  final String id;
  final String content;
  const SettingData({required this.id, required this.content});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content'] = Variable<String>(content);
    return map;
  }

  SettingCompanion toCompanion(bool nullToAbsent) {
    return SettingCompanion(id: Value(id), content: Value(content));
  }

  factory SettingData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingData(
      id: serializer.fromJson<String>(json['id']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'content': serializer.toJson<String>(content),
    };
  }

  SettingData copyWith({String? id, String? content}) =>
      SettingData(id: id ?? this.id, content: content ?? this.content);
  SettingData copyWithCompanion(SettingCompanion data) {
    return SettingData(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingData(')
          ..write('id: $id, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingData &&
          other.id == this.id &&
          other.content == this.content);
}

class SettingCompanion extends UpdateCompanion<SettingData> {
  final Value<String> id;
  final Value<String> content;
  final Value<int> rowid;
  const SettingCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingCompanion.insert({
    required String id,
    required String content,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       content = Value(content);
  static Insertable<SettingData> custom({
    Expression<String>? id,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingCompanion copyWith({
    Value<String>? id,
    Value<String>? content,
    Value<int>? rowid,
  }) {
    return SettingCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $Mib3Table mib3 = $Mib3Table(this);
  late final $Mib3SubTable mib3Sub = $Mib3SubTable(this);
  late final $SettingTable setting = $SettingTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [mib3, mib3Sub, setting];
}

typedef $$Mib3TableCreateCompanionBuilder =
    Mib3Companion Function({
      required String id,
      required String tb,
      required String wan,
      required String content,
      Value<int> rowid,
    });
typedef $$Mib3TableUpdateCompanionBuilder =
    Mib3Companion Function({
      Value<String> id,
      Value<String> tb,
      Value<String> wan,
      Value<String> content,
      Value<int> rowid,
    });

class $$Mib3TableFilterComposer extends Composer<_$AppDatabase, $Mib3Table> {
  $$Mib3TableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tb => $composableBuilder(
    column: $table.tb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wan => $composableBuilder(
    column: $table.wan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );
}

class $$Mib3TableOrderingComposer extends Composer<_$AppDatabase, $Mib3Table> {
  $$Mib3TableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tb => $composableBuilder(
    column: $table.tb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wan => $composableBuilder(
    column: $table.wan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$Mib3TableAnnotationComposer
    extends Composer<_$AppDatabase, $Mib3Table> {
  $$Mib3TableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tb =>
      $composableBuilder(column: $table.tb, builder: (column) => column);

  GeneratedColumn<String> get wan =>
      $composableBuilder(column: $table.wan, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);
}

class $$Mib3TableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $Mib3Table,
          Mib3Data,
          $$Mib3TableFilterComposer,
          $$Mib3TableOrderingComposer,
          $$Mib3TableAnnotationComposer,
          $$Mib3TableCreateCompanionBuilder,
          $$Mib3TableUpdateCompanionBuilder,
          (Mib3Data, BaseReferences<_$AppDatabase, $Mib3Table, Mib3Data>),
          Mib3Data,
          PrefetchHooks Function()
        > {
  $$Mib3TableTableManager(_$AppDatabase db, $Mib3Table table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$Mib3TableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$Mib3TableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$Mib3TableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tb = const Value.absent(),
                Value<String> wan = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => Mib3Companion(
                id: id,
                tb: tb,
                wan: wan,
                content: content,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tb,
                required String wan,
                required String content,
                Value<int> rowid = const Value.absent(),
              }) => Mib3Companion.insert(
                id: id,
                tb: tb,
                wan: wan,
                content: content,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$Mib3TableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $Mib3Table,
      Mib3Data,
      $$Mib3TableFilterComposer,
      $$Mib3TableOrderingComposer,
      $$Mib3TableAnnotationComposer,
      $$Mib3TableCreateCompanionBuilder,
      $$Mib3TableUpdateCompanionBuilder,
      (Mib3Data, BaseReferences<_$AppDatabase, $Mib3Table, Mib3Data>),
      Mib3Data,
      PrefetchHooks Function()
    >;
typedef $$Mib3SubTableCreateCompanionBuilder =
    Mib3SubCompanion Function({
      required String id,
      required String masterId,
      required String sdate,
      required String content,
      Value<int> rowid,
    });
typedef $$Mib3SubTableUpdateCompanionBuilder =
    Mib3SubCompanion Function({
      Value<String> id,
      Value<String> masterId,
      Value<String> sdate,
      Value<String> content,
      Value<int> rowid,
    });

class $$Mib3SubTableFilterComposer
    extends Composer<_$AppDatabase, $Mib3SubTable> {
  $$Mib3SubTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get masterId => $composableBuilder(
    column: $table.masterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sdate => $composableBuilder(
    column: $table.sdate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );
}

class $$Mib3SubTableOrderingComposer
    extends Composer<_$AppDatabase, $Mib3SubTable> {
  $$Mib3SubTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get masterId => $composableBuilder(
    column: $table.masterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sdate => $composableBuilder(
    column: $table.sdate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$Mib3SubTableAnnotationComposer
    extends Composer<_$AppDatabase, $Mib3SubTable> {
  $$Mib3SubTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get masterId =>
      $composableBuilder(column: $table.masterId, builder: (column) => column);

  GeneratedColumn<String> get sdate =>
      $composableBuilder(column: $table.sdate, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);
}

class $$Mib3SubTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $Mib3SubTable,
          Mib3SubData,
          $$Mib3SubTableFilterComposer,
          $$Mib3SubTableOrderingComposer,
          $$Mib3SubTableAnnotationComposer,
          $$Mib3SubTableCreateCompanionBuilder,
          $$Mib3SubTableUpdateCompanionBuilder,
          (
            Mib3SubData,
            BaseReferences<_$AppDatabase, $Mib3SubTable, Mib3SubData>,
          ),
          Mib3SubData,
          PrefetchHooks Function()
        > {
  $$Mib3SubTableTableManager(_$AppDatabase db, $Mib3SubTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$Mib3SubTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$Mib3SubTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$Mib3SubTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> masterId = const Value.absent(),
                Value<String> sdate = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => Mib3SubCompanion(
                id: id,
                masterId: masterId,
                sdate: sdate,
                content: content,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String masterId,
                required String sdate,
                required String content,
                Value<int> rowid = const Value.absent(),
              }) => Mib3SubCompanion.insert(
                id: id,
                masterId: masterId,
                sdate: sdate,
                content: content,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$Mib3SubTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $Mib3SubTable,
      Mib3SubData,
      $$Mib3SubTableFilterComposer,
      $$Mib3SubTableOrderingComposer,
      $$Mib3SubTableAnnotationComposer,
      $$Mib3SubTableCreateCompanionBuilder,
      $$Mib3SubTableUpdateCompanionBuilder,
      (Mib3SubData, BaseReferences<_$AppDatabase, $Mib3SubTable, Mib3SubData>),
      Mib3SubData,
      PrefetchHooks Function()
    >;
typedef $$SettingTableCreateCompanionBuilder =
    SettingCompanion Function({
      required String id,
      required String content,
      Value<int> rowid,
    });
typedef $$SettingTableUpdateCompanionBuilder =
    SettingCompanion Function({
      Value<String> id,
      Value<String> content,
      Value<int> rowid,
    });

class $$SettingTableFilterComposer
    extends Composer<_$AppDatabase, $SettingTable> {
  $$SettingTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingTable> {
  $$SettingTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingTable> {
  $$SettingTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);
}

class $$SettingTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingTable,
          SettingData,
          $$SettingTableFilterComposer,
          $$SettingTableOrderingComposer,
          $$SettingTableAnnotationComposer,
          $$SettingTableCreateCompanionBuilder,
          $$SettingTableUpdateCompanionBuilder,
          (
            SettingData,
            BaseReferences<_$AppDatabase, $SettingTable, SettingData>,
          ),
          SettingData,
          PrefetchHooks Function()
        > {
  $$SettingTableTableManager(_$AppDatabase db, $SettingTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingCompanion(id: id, content: content, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String content,
                Value<int> rowid = const Value.absent(),
              }) => SettingCompanion.insert(
                id: id,
                content: content,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingTable,
      SettingData,
      $$SettingTableFilterComposer,
      $$SettingTableOrderingComposer,
      $$SettingTableAnnotationComposer,
      $$SettingTableCreateCompanionBuilder,
      $$SettingTableUpdateCompanionBuilder,
      (SettingData, BaseReferences<_$AppDatabase, $SettingTable, SettingData>),
      SettingData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$Mib3TableTableManager get mib3 => $$Mib3TableTableManager(_db, _db.mib3);
  $$Mib3SubTableTableManager get mib3Sub =>
      $$Mib3SubTableTableManager(_db, _db.mib3Sub);
  $$SettingTableTableManager get setting =>
      $$SettingTableTableManager(_db, _db.setting);
}
