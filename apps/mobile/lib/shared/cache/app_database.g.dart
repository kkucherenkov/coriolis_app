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

class $PendingMutationsTable extends PendingMutations
    with TableInfo<$PendingMutationsTable, PendingMutationsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingMutationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _headersJsonMeta = const VerificationMeta(
    'headersJson',
  );
  @override
  late final GeneratedColumn<String> headersJson = GeneratedColumn<String>(
    'headers_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    method,
    path,
    body,
    headersJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_mutations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingMutationsData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('headers_json')) {
      context.handle(
        _headersJsonMeta,
        headersJson.isAcceptableOrUnknown(
          data['headers_json']!,
          _headersJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_headersJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingMutationsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingMutationsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      ),
      headersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headers_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PendingMutationsTable createAlias(String alias) {
    return $PendingMutationsTable(attachedDatabase, alias);
  }
}

class PendingMutationsData extends DataClass
    implements Insertable<PendingMutationsData> {
  final String id;
  final String method;
  final String path;
  final String? body;
  final String headersJson;
  final DateTime createdAt;
  const PendingMutationsData({
    required this.id,
    required this.method,
    required this.path,
    this.body,
    required this.headersJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['method'] = Variable<String>(method);
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    map['headers_json'] = Variable<String>(headersJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingMutationsCompanion toCompanion(bool nullToAbsent) {
    return PendingMutationsCompanion(
      id: Value(id),
      method: Value(method),
      path: Value(path),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      headersJson: Value(headersJson),
      createdAt: Value(createdAt),
    );
  }

  factory PendingMutationsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingMutationsData(
      id: serializer.fromJson<String>(json['id']),
      method: serializer.fromJson<String>(json['method']),
      path: serializer.fromJson<String>(json['path']),
      body: serializer.fromJson<String?>(json['body']),
      headersJson: serializer.fromJson<String>(json['headersJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'method': serializer.toJson<String>(method),
      'path': serializer.toJson<String>(path),
      'body': serializer.toJson<String?>(body),
      'headersJson': serializer.toJson<String>(headersJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingMutationsData copyWith({
    String? id,
    String? method,
    String? path,
    Value<String?> body = const Value.absent(),
    String? headersJson,
    DateTime? createdAt,
  }) => PendingMutationsData(
    id: id ?? this.id,
    method: method ?? this.method,
    path: path ?? this.path,
    body: body.present ? body.value : this.body,
    headersJson: headersJson ?? this.headersJson,
    createdAt: createdAt ?? this.createdAt,
  );
  PendingMutationsData copyWithCompanion(PendingMutationsCompanion data) {
    return PendingMutationsData(
      id: data.id.present ? data.id.value : this.id,
      method: data.method.present ? data.method.value : this.method,
      path: data.path.present ? data.path.value : this.path,
      body: data.body.present ? data.body.value : this.body,
      headersJson: data.headersJson.present
          ? data.headersJson.value
          : this.headersJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingMutationsData(')
          ..write('id: $id, ')
          ..write('method: $method, ')
          ..write('path: $path, ')
          ..write('body: $body, ')
          ..write('headersJson: $headersJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, method, path, body, headersJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingMutationsData &&
          other.id == this.id &&
          other.method == this.method &&
          other.path == this.path &&
          other.body == this.body &&
          other.headersJson == this.headersJson &&
          other.createdAt == this.createdAt);
}

class PendingMutationsCompanion extends UpdateCompanion<PendingMutationsData> {
  final Value<String> id;
  final Value<String> method;
  final Value<String> path;
  final Value<String?> body;
  final Value<String> headersJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PendingMutationsCompanion({
    this.id = const Value.absent(),
    this.method = const Value.absent(),
    this.path = const Value.absent(),
    this.body = const Value.absent(),
    this.headersJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingMutationsCompanion.insert({
    required String id,
    required String method,
    required String path,
    this.body = const Value.absent(),
    required String headersJson,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       method = Value(method),
       path = Value(path),
       headersJson = Value(headersJson),
       createdAt = Value(createdAt);
  static Insertable<PendingMutationsData> custom({
    Expression<String>? id,
    Expression<String>? method,
    Expression<String>? path,
    Expression<String>? body,
    Expression<String>? headersJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (method != null) 'method': method,
      if (path != null) 'path': path,
      if (body != null) 'body': body,
      if (headersJson != null) 'headers_json': headersJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingMutationsCompanion copyWith({
    Value<String>? id,
    Value<String>? method,
    Value<String>? path,
    Value<String?>? body,
    Value<String>? headersJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PendingMutationsCompanion(
      id: id ?? this.id,
      method: method ?? this.method,
      path: path ?? this.path,
      body: body ?? this.body,
      headersJson: headersJson ?? this.headersJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (headersJson.present) {
      map['headers_json'] = Variable<String>(headersJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingMutationsCompanion(')
          ..write('id: $id, ')
          ..write('method: $method, ')
          ..write('path: $path, ')
          ..write('body: $body, ')
          ..write('headersJson: $headersJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShipsCacheTable extends ShipsCache
    with TableInfo<$ShipsCacheTable, ShipsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShipsCacheTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'ships_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShipsCacheData> instance, {
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
  ShipsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShipsCacheData(
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
  $ShipsCacheTable createAlias(String alias) {
    return $ShipsCacheTable(attachedDatabase, alias);
  }
}

class ShipsCacheData extends DataClass implements Insertable<ShipsCacheData> {
  final String id;
  final String payloadJson;
  final DateTime wireUpdatedAt;
  final DateTime cachedAt;
  const ShipsCacheData({
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

  ShipsCacheCompanion toCompanion(bool nullToAbsent) {
    return ShipsCacheCompanion(
      id: Value(id),
      payloadJson: Value(payloadJson),
      wireUpdatedAt: Value(wireUpdatedAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory ShipsCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShipsCacheData(
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

  ShipsCacheData copyWith({
    String? id,
    String? payloadJson,
    DateTime? wireUpdatedAt,
    DateTime? cachedAt,
  }) => ShipsCacheData(
    id: id ?? this.id,
    payloadJson: payloadJson ?? this.payloadJson,
    wireUpdatedAt: wireUpdatedAt ?? this.wireUpdatedAt,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  ShipsCacheData copyWithCompanion(ShipsCacheCompanion data) {
    return ShipsCacheData(
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
    return (StringBuffer('ShipsCacheData(')
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
      (other is ShipsCacheData &&
          other.id == this.id &&
          other.payloadJson == this.payloadJson &&
          other.wireUpdatedAt == this.wireUpdatedAt &&
          other.cachedAt == this.cachedAt);
}

class ShipsCacheCompanion extends UpdateCompanion<ShipsCacheData> {
  final Value<String> id;
  final Value<String> payloadJson;
  final Value<DateTime> wireUpdatedAt;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const ShipsCacheCompanion({
    this.id = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.wireUpdatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShipsCacheCompanion.insert({
    required String id,
    required String payloadJson,
    required DateTime wireUpdatedAt,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payloadJson = Value(payloadJson),
       wireUpdatedAt = Value(wireUpdatedAt),
       cachedAt = Value(cachedAt);
  static Insertable<ShipsCacheData> custom({
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

  ShipsCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? payloadJson,
    Value<DateTime>? wireUpdatedAt,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return ShipsCacheCompanion(
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
    return (StringBuffer('ShipsCacheCompanion(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('wireUpdatedAt: $wireUpdatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameSessionsCacheTable extends GameSessionsCache
    with TableInfo<$GameSessionsCacheTable, GameSessionsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameSessionsCacheTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'game_sessions_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameSessionsCacheData> instance, {
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
  GameSessionsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameSessionsCacheData(
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
  $GameSessionsCacheTable createAlias(String alias) {
    return $GameSessionsCacheTable(attachedDatabase, alias);
  }
}

class GameSessionsCacheData extends DataClass
    implements Insertable<GameSessionsCacheData> {
  final String id;
  final String payloadJson;
  final DateTime wireUpdatedAt;
  final DateTime cachedAt;
  const GameSessionsCacheData({
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

  GameSessionsCacheCompanion toCompanion(bool nullToAbsent) {
    return GameSessionsCacheCompanion(
      id: Value(id),
      payloadJson: Value(payloadJson),
      wireUpdatedAt: Value(wireUpdatedAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory GameSessionsCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameSessionsCacheData(
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

  GameSessionsCacheData copyWith({
    String? id,
    String? payloadJson,
    DateTime? wireUpdatedAt,
    DateTime? cachedAt,
  }) => GameSessionsCacheData(
    id: id ?? this.id,
    payloadJson: payloadJson ?? this.payloadJson,
    wireUpdatedAt: wireUpdatedAt ?? this.wireUpdatedAt,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  GameSessionsCacheData copyWithCompanion(GameSessionsCacheCompanion data) {
    return GameSessionsCacheData(
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
    return (StringBuffer('GameSessionsCacheData(')
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
      (other is GameSessionsCacheData &&
          other.id == this.id &&
          other.payloadJson == this.payloadJson &&
          other.wireUpdatedAt == this.wireUpdatedAt &&
          other.cachedAt == this.cachedAt);
}

class GameSessionsCacheCompanion
    extends UpdateCompanion<GameSessionsCacheData> {
  final Value<String> id;
  final Value<String> payloadJson;
  final Value<DateTime> wireUpdatedAt;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const GameSessionsCacheCompanion({
    this.id = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.wireUpdatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameSessionsCacheCompanion.insert({
    required String id,
    required String payloadJson,
    required DateTime wireUpdatedAt,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payloadJson = Value(payloadJson),
       wireUpdatedAt = Value(wireUpdatedAt),
       cachedAt = Value(cachedAt);
  static Insertable<GameSessionsCacheData> custom({
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

  GameSessionsCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? payloadJson,
    Value<DateTime>? wireUpdatedAt,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return GameSessionsCacheCompanion(
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
    return (StringBuffer('GameSessionsCacheCompanion(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('wireUpdatedAt: $wireUpdatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayerMembershipsCacheTable extends PlayerMembershipsCache
    with TableInfo<$PlayerMembershipsCacheTable, PlayerMembershipsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerMembershipsCacheTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'player_memberships_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerMembershipsCacheData> instance, {
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
  PlayerMembershipsCacheData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerMembershipsCacheData(
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
  $PlayerMembershipsCacheTable createAlias(String alias) {
    return $PlayerMembershipsCacheTable(attachedDatabase, alias);
  }
}

class PlayerMembershipsCacheData extends DataClass
    implements Insertable<PlayerMembershipsCacheData> {
  final String id;
  final String payloadJson;
  final DateTime wireUpdatedAt;
  final DateTime cachedAt;
  const PlayerMembershipsCacheData({
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

  PlayerMembershipsCacheCompanion toCompanion(bool nullToAbsent) {
    return PlayerMembershipsCacheCompanion(
      id: Value(id),
      payloadJson: Value(payloadJson),
      wireUpdatedAt: Value(wireUpdatedAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory PlayerMembershipsCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerMembershipsCacheData(
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

  PlayerMembershipsCacheData copyWith({
    String? id,
    String? payloadJson,
    DateTime? wireUpdatedAt,
    DateTime? cachedAt,
  }) => PlayerMembershipsCacheData(
    id: id ?? this.id,
    payloadJson: payloadJson ?? this.payloadJson,
    wireUpdatedAt: wireUpdatedAt ?? this.wireUpdatedAt,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  PlayerMembershipsCacheData copyWithCompanion(
    PlayerMembershipsCacheCompanion data,
  ) {
    return PlayerMembershipsCacheData(
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
    return (StringBuffer('PlayerMembershipsCacheData(')
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
      (other is PlayerMembershipsCacheData &&
          other.id == this.id &&
          other.payloadJson == this.payloadJson &&
          other.wireUpdatedAt == this.wireUpdatedAt &&
          other.cachedAt == this.cachedAt);
}

class PlayerMembershipsCacheCompanion
    extends UpdateCompanion<PlayerMembershipsCacheData> {
  final Value<String> id;
  final Value<String> payloadJson;
  final Value<DateTime> wireUpdatedAt;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const PlayerMembershipsCacheCompanion({
    this.id = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.wireUpdatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayerMembershipsCacheCompanion.insert({
    required String id,
    required String payloadJson,
    required DateTime wireUpdatedAt,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payloadJson = Value(payloadJson),
       wireUpdatedAt = Value(wireUpdatedAt),
       cachedAt = Value(cachedAt);
  static Insertable<PlayerMembershipsCacheData> custom({
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

  PlayerMembershipsCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? payloadJson,
    Value<DateTime>? wireUpdatedAt,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return PlayerMembershipsCacheCompanion(
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
    return (StringBuffer('PlayerMembershipsCacheCompanion(')
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
  late final $PendingMutationsTable pendingMutations = $PendingMutationsTable(
    this,
  );
  late final $ShipsCacheTable shipsCache = $ShipsCacheTable(this);
  late final $GameSessionsCacheTable gameSessionsCache =
      $GameSessionsCacheTable(this);
  late final $PlayerMembershipsCacheTable playerMembershipsCache =
      $PlayerMembershipsCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    charactersCache,
    pendingMutations,
    shipsCache,
    gameSessionsCache,
    playerMembershipsCache,
  ];
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
typedef $$PendingMutationsTableCreateCompanionBuilder =
    PendingMutationsCompanion Function({
      required String id,
      required String method,
      required String path,
      Value<String?> body,
      required String headersJson,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PendingMutationsTableUpdateCompanionBuilder =
    PendingMutationsCompanion Function({
      Value<String> id,
      Value<String> method,
      Value<String> path,
      Value<String?> body,
      Value<String> headersJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PendingMutationsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingMutationsTable> {
  $$PendingMutationsTableFilterComposer({
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

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingMutationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingMutationsTable> {
  $$PendingMutationsTableOrderingComposer({
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

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingMutationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingMutationsTable> {
  $$PendingMutationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PendingMutationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingMutationsTable,
          PendingMutationsData,
          $$PendingMutationsTableFilterComposer,
          $$PendingMutationsTableOrderingComposer,
          $$PendingMutationsTableAnnotationComposer,
          $$PendingMutationsTableCreateCompanionBuilder,
          $$PendingMutationsTableUpdateCompanionBuilder,
          (
            PendingMutationsData,
            BaseReferences<
              _$AppDatabase,
              $PendingMutationsTable,
              PendingMutationsData
            >,
          ),
          PendingMutationsData,
          PrefetchHooks Function()
        > {
  $$PendingMutationsTableTableManager(
    _$AppDatabase db,
    $PendingMutationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingMutationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingMutationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingMutationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<String> headersJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingMutationsCompanion(
                id: id,
                method: method,
                path: path,
                body: body,
                headersJson: headersJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String method,
                required String path,
                Value<String?> body = const Value.absent(),
                required String headersJson,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PendingMutationsCompanion.insert(
                id: id,
                method: method,
                path: path,
                body: body,
                headersJson: headersJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingMutationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingMutationsTable,
      PendingMutationsData,
      $$PendingMutationsTableFilterComposer,
      $$PendingMutationsTableOrderingComposer,
      $$PendingMutationsTableAnnotationComposer,
      $$PendingMutationsTableCreateCompanionBuilder,
      $$PendingMutationsTableUpdateCompanionBuilder,
      (
        PendingMutationsData,
        BaseReferences<
          _$AppDatabase,
          $PendingMutationsTable,
          PendingMutationsData
        >,
      ),
      PendingMutationsData,
      PrefetchHooks Function()
    >;
typedef $$ShipsCacheTableCreateCompanionBuilder =
    ShipsCacheCompanion Function({
      required String id,
      required String payloadJson,
      required DateTime wireUpdatedAt,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$ShipsCacheTableUpdateCompanionBuilder =
    ShipsCacheCompanion Function({
      Value<String> id,
      Value<String> payloadJson,
      Value<DateTime> wireUpdatedAt,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$ShipsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $ShipsCacheTable> {
  $$ShipsCacheTableFilterComposer({
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

class $$ShipsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $ShipsCacheTable> {
  $$ShipsCacheTableOrderingComposer({
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

class $$ShipsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShipsCacheTable> {
  $$ShipsCacheTableAnnotationComposer({
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

class $$ShipsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShipsCacheTable,
          ShipsCacheData,
          $$ShipsCacheTableFilterComposer,
          $$ShipsCacheTableOrderingComposer,
          $$ShipsCacheTableAnnotationComposer,
          $$ShipsCacheTableCreateCompanionBuilder,
          $$ShipsCacheTableUpdateCompanionBuilder,
          (
            ShipsCacheData,
            BaseReferences<_$AppDatabase, $ShipsCacheTable, ShipsCacheData>,
          ),
          ShipsCacheData,
          PrefetchHooks Function()
        > {
  $$ShipsCacheTableTableManager(_$AppDatabase db, $ShipsCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShipsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShipsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShipsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> wireUpdatedAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShipsCacheCompanion(
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
              }) => ShipsCacheCompanion.insert(
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

typedef $$ShipsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShipsCacheTable,
      ShipsCacheData,
      $$ShipsCacheTableFilterComposer,
      $$ShipsCacheTableOrderingComposer,
      $$ShipsCacheTableAnnotationComposer,
      $$ShipsCacheTableCreateCompanionBuilder,
      $$ShipsCacheTableUpdateCompanionBuilder,
      (
        ShipsCacheData,
        BaseReferences<_$AppDatabase, $ShipsCacheTable, ShipsCacheData>,
      ),
      ShipsCacheData,
      PrefetchHooks Function()
    >;
typedef $$GameSessionsCacheTableCreateCompanionBuilder =
    GameSessionsCacheCompanion Function({
      required String id,
      required String payloadJson,
      required DateTime wireUpdatedAt,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$GameSessionsCacheTableUpdateCompanionBuilder =
    GameSessionsCacheCompanion Function({
      Value<String> id,
      Value<String> payloadJson,
      Value<DateTime> wireUpdatedAt,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$GameSessionsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $GameSessionsCacheTable> {
  $$GameSessionsCacheTableFilterComposer({
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

class $$GameSessionsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $GameSessionsCacheTable> {
  $$GameSessionsCacheTableOrderingComposer({
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

class $$GameSessionsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameSessionsCacheTable> {
  $$GameSessionsCacheTableAnnotationComposer({
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

class $$GameSessionsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameSessionsCacheTable,
          GameSessionsCacheData,
          $$GameSessionsCacheTableFilterComposer,
          $$GameSessionsCacheTableOrderingComposer,
          $$GameSessionsCacheTableAnnotationComposer,
          $$GameSessionsCacheTableCreateCompanionBuilder,
          $$GameSessionsCacheTableUpdateCompanionBuilder,
          (
            GameSessionsCacheData,
            BaseReferences<
              _$AppDatabase,
              $GameSessionsCacheTable,
              GameSessionsCacheData
            >,
          ),
          GameSessionsCacheData,
          PrefetchHooks Function()
        > {
  $$GameSessionsCacheTableTableManager(
    _$AppDatabase db,
    $GameSessionsCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameSessionsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameSessionsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameSessionsCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> wireUpdatedAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameSessionsCacheCompanion(
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
              }) => GameSessionsCacheCompanion.insert(
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

typedef $$GameSessionsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameSessionsCacheTable,
      GameSessionsCacheData,
      $$GameSessionsCacheTableFilterComposer,
      $$GameSessionsCacheTableOrderingComposer,
      $$GameSessionsCacheTableAnnotationComposer,
      $$GameSessionsCacheTableCreateCompanionBuilder,
      $$GameSessionsCacheTableUpdateCompanionBuilder,
      (
        GameSessionsCacheData,
        BaseReferences<
          _$AppDatabase,
          $GameSessionsCacheTable,
          GameSessionsCacheData
        >,
      ),
      GameSessionsCacheData,
      PrefetchHooks Function()
    >;
typedef $$PlayerMembershipsCacheTableCreateCompanionBuilder =
    PlayerMembershipsCacheCompanion Function({
      required String id,
      required String payloadJson,
      required DateTime wireUpdatedAt,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$PlayerMembershipsCacheTableUpdateCompanionBuilder =
    PlayerMembershipsCacheCompanion Function({
      Value<String> id,
      Value<String> payloadJson,
      Value<DateTime> wireUpdatedAt,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$PlayerMembershipsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerMembershipsCacheTable> {
  $$PlayerMembershipsCacheTableFilterComposer({
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

class $$PlayerMembershipsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerMembershipsCacheTable> {
  $$PlayerMembershipsCacheTableOrderingComposer({
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

class $$PlayerMembershipsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerMembershipsCacheTable> {
  $$PlayerMembershipsCacheTableAnnotationComposer({
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

class $$PlayerMembershipsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerMembershipsCacheTable,
          PlayerMembershipsCacheData,
          $$PlayerMembershipsCacheTableFilterComposer,
          $$PlayerMembershipsCacheTableOrderingComposer,
          $$PlayerMembershipsCacheTableAnnotationComposer,
          $$PlayerMembershipsCacheTableCreateCompanionBuilder,
          $$PlayerMembershipsCacheTableUpdateCompanionBuilder,
          (
            PlayerMembershipsCacheData,
            BaseReferences<
              _$AppDatabase,
              $PlayerMembershipsCacheTable,
              PlayerMembershipsCacheData
            >,
          ),
          PlayerMembershipsCacheData,
          PrefetchHooks Function()
        > {
  $$PlayerMembershipsCacheTableTableManager(
    _$AppDatabase db,
    $PlayerMembershipsCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerMembershipsCacheTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PlayerMembershipsCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlayerMembershipsCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> wireUpdatedAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayerMembershipsCacheCompanion(
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
              }) => PlayerMembershipsCacheCompanion.insert(
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

typedef $$PlayerMembershipsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerMembershipsCacheTable,
      PlayerMembershipsCacheData,
      $$PlayerMembershipsCacheTableFilterComposer,
      $$PlayerMembershipsCacheTableOrderingComposer,
      $$PlayerMembershipsCacheTableAnnotationComposer,
      $$PlayerMembershipsCacheTableCreateCompanionBuilder,
      $$PlayerMembershipsCacheTableUpdateCompanionBuilder,
      (
        PlayerMembershipsCacheData,
        BaseReferences<
          _$AppDatabase,
          $PlayerMembershipsCacheTable,
          PlayerMembershipsCacheData
        >,
      ),
      PlayerMembershipsCacheData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CharactersCacheTableTableManager get charactersCache =>
      $$CharactersCacheTableTableManager(_db, _db.charactersCache);
  $$PendingMutationsTableTableManager get pendingMutations =>
      $$PendingMutationsTableTableManager(_db, _db.pendingMutations);
  $$ShipsCacheTableTableManager get shipsCache =>
      $$ShipsCacheTableTableManager(_db, _db.shipsCache);
  $$GameSessionsCacheTableTableManager get gameSessionsCache =>
      $$GameSessionsCacheTableTableManager(_db, _db.gameSessionsCache);
  $$PlayerMembershipsCacheTableTableManager get playerMembershipsCache =>
      $$PlayerMembershipsCacheTableTableManager(
        _db,
        _db.playerMembershipsCache,
      );
}
