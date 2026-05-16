// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CharactersCacheTable extends CharactersCache
    with TableInfo<$CharactersCacheTable, CharactersCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharactersCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wireUpdatedAtMeta = const VerificationMeta(
    'wireUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> wireUpdatedAt =
      GeneratedColumn<DateTime>(
        'wire_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    payloadJson,
    wireUpdatedAt,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'characters_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharactersCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('wire_updated_at')) {
      context.handle(
        _wireUpdatedAtMeta,
        wireUpdatedAt.isAcceptableOrUnknown(
          data['wire_updated_at']!,
          _wireUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wireUpdatedAtMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CharactersCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharactersCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      wireUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}wire_updated_at'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CharactersCacheTable createAlias(String alias) {
    return $CharactersCacheTable(attachedDatabase, alias);
  }
}

class CharactersCacheData extends DataClass
    implements Insertable<CharactersCacheData> {
  final String id;
  final String payloadJson;
  final DateTime wireUpdatedAt;
  final DateTime cachedAt;
  const CharactersCacheData({
    required this.id,
    required this.payloadJson,
    required this.wireUpdatedAt,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload_json'] = Variable<String>(payloadJson);
    map['wire_updated_at'] = Variable<DateTime>(wireUpdatedAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CharactersCacheCompanion toCompanion(bool nullToAbsent) {
    return CharactersCacheCompanion(
      id: Value(id),
      payloadJson: Value(payloadJson),
      wireUpdatedAt: Value(wireUpdatedAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory CharactersCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharactersCacheData(
      id: serializer.fromJson<String>(json['id']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      wireUpdatedAt: serializer.fromJson<DateTime>(json['wireUpdatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'wireUpdatedAt': serializer.toJson<DateTime>(wireUpdatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CharactersCacheData copyWith({
    String? id,
    String? payloadJson,
    DateTime? wireUpdatedAt,
    DateTime? cachedAt,
  }) => CharactersCacheData(
    id: id ?? this.id,
    payloadJson: payloadJson ?? this.payloadJson,
    wireUpdatedAt: wireUpdatedAt ?? this.wireUpdatedAt,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CharactersCacheData copyWithCompanion(CharactersCacheCompanion data) {
    return CharactersCacheData(
      id: data.id.present ? data.id.value : this.id,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      wireUpdatedAt: data.wireUpdatedAt.present
          ? data.wireUpdatedAt.value
          : this.wireUpdatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharactersCacheData(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('wireUpdatedAt: $wireUpdatedAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payloadJson, wireUpdatedAt, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharactersCacheData &&
          other.id == this.id &&
          other.payloadJson == this.payloadJson &&
          other.wireUpdatedAt == this.wireUpdatedAt &&
          other.cachedAt == this.cachedAt);
}

class CharactersCacheCompanion extends UpdateCompanion<CharactersCacheData> {
  final Value<String> id;
  final Value<String> payloadJson;
  final Value<DateTime> wireUpdatedAt;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CharactersCacheCompanion({
    this.id = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.wireUpdatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CharactersCacheCompanion.insert({
    required String id,
    required String payloadJson,
    required DateTime wireUpdatedAt,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payloadJson = Value(payloadJson),
       wireUpdatedAt = Value(wireUpdatedAt),
       cachedAt = Value(cachedAt);
  static Insertable<CharactersCacheData> custom({
    Expression<String>? id,
    Expression<String>? payloadJson,
    Expression<DateTime>? wireUpdatedAt,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (wireUpdatedAt != null) 'wire_updated_at': wireUpdatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CharactersCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? payloadJson,
    Value<DateTime>? wireUpdatedAt,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CharactersCacheCompanion(
      id: id ?? this.id,
      payloadJson: payloadJson ?? this.payloadJson,
      wireUpdatedAt: wireUpdatedAt ?? this.wireUpdatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (wireUpdatedAt.present) {
      map['wire_updated_at'] = Variable<DateTime>(wireUpdatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharactersCacheCompanion(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('wireUpdatedAt: $wireUpdatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CharactersCacheTable charactersCache = $CharactersCacheTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [charactersCache];
}

typedef $$CharactersCacheTableCreateCompanionBuilder =
    CharactersCacheCompanion Function({
      required String id,
      required String payloadJson,
      required DateTime wireUpdatedAt,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$CharactersCacheTableUpdateCompanionBuilder =
    CharactersCacheCompanion Function({
      Value<String> id,
      Value<String> payloadJson,
      Value<DateTime> wireUpdatedAt,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CharactersCacheTableFilterComposer
    extends Composer<_$AppDatabase, $CharactersCacheTable> {
  $$CharactersCacheTableFilterComposer({
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

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get wireUpdatedAt => $composableBuilder(
    column: $table.wireUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CharactersCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $CharactersCacheTable> {
  $$CharactersCacheTableOrderingComposer({
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

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get wireUpdatedAt => $composableBuilder(
    column: $table.wireUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CharactersCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharactersCacheTable> {
  $$CharactersCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get wireUpdatedAt => $composableBuilder(
    column: $table.wireUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CharactersCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharactersCacheTable,
          CharactersCacheData,
          $$CharactersCacheTableFilterComposer,
          $$CharactersCacheTableOrderingComposer,
          $$CharactersCacheTableAnnotationComposer,
          $$CharactersCacheTableCreateCompanionBuilder,
          $$CharactersCacheTableUpdateCompanionBuilder,
          (
            CharactersCacheData,
            BaseReferences<
              _$AppDatabase,
              $CharactersCacheTable,
              CharactersCacheData
            >,
          ),
          CharactersCacheData,
          PrefetchHooks Function()
        > {
  $$CharactersCacheTableTableManager(
    _$AppDatabase db,
    $CharactersCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharactersCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharactersCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharactersCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> wireUpdatedAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharactersCacheCompanion(
                id: id,
                payloadJson: payloadJson,
                wireUpdatedAt: wireUpdatedAt,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String payloadJson,
                required DateTime wireUpdatedAt,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => CharactersCacheCompanion.insert(
                id: id,
                payloadJson: payloadJson,
                wireUpdatedAt: wireUpdatedAt,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CharactersCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharactersCacheTable,
      CharactersCacheData,
      $$CharactersCacheTableFilterComposer,
      $$CharactersCacheTableOrderingComposer,
      $$CharactersCacheTableAnnotationComposer,
      $$CharactersCacheTableCreateCompanionBuilder,
      $$CharactersCacheTableUpdateCompanionBuilder,
      (
        CharactersCacheData,
        BaseReferences<
          _$AppDatabase,
          $CharactersCacheTable,
          CharactersCacheData
        >,
      ),
      CharactersCacheData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CharactersCacheTableTableManager get charactersCache =>
      $$CharactersCacheTableTableManager(_db, _db.charactersCache);
}
