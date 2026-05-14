// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_export_game_session.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MeExportGameSession extends MeExportGameSession {
  @override
  final BuiltList<MeExportEncounter> encounters;
  @override
  final String id;
  @override
  final String ownerId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final GameSessionStatus status;
  @override
  final int dpCount;
  @override
  final BuiltList<String> characterIds;
  @override
  final String? shipId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$MeExportGameSession(
          [void Function(MeExportGameSessionBuilder)? updates]) =>
      (MeExportGameSessionBuilder()..update(updates))._build();

  _$MeExportGameSession._(
      {required this.encounters,
      required this.id,
      required this.ownerId,
      required this.name,
      this.description,
      required this.status,
      required this.dpCount,
      required this.characterIds,
      this.shipId,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  MeExportGameSession rebuild(
          void Function(MeExportGameSessionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeExportGameSessionBuilder toBuilder() =>
      MeExportGameSessionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeExportGameSession &&
        encounters == other.encounters &&
        id == other.id &&
        ownerId == other.ownerId &&
        name == other.name &&
        description == other.description &&
        status == other.status &&
        dpCount == other.dpCount &&
        characterIds == other.characterIds &&
        shipId == other.shipId &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, encounters.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, ownerId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, dpCount.hashCode);
    _$hash = $jc(_$hash, characterIds.hashCode);
    _$hash = $jc(_$hash, shipId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MeExportGameSession')
          ..add('encounters', encounters)
          ..add('id', id)
          ..add('ownerId', ownerId)
          ..add('name', name)
          ..add('description', description)
          ..add('status', status)
          ..add('dpCount', dpCount)
          ..add('characterIds', characterIds)
          ..add('shipId', shipId)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class MeExportGameSessionBuilder
    implements
        Builder<MeExportGameSession, MeExportGameSessionBuilder>,
        GameSessionBuilder {
  _$MeExportGameSession? _$v;

  ListBuilder<MeExportEncounter>? _encounters;
  ListBuilder<MeExportEncounter> get encounters =>
      _$this._encounters ??= ListBuilder<MeExportEncounter>();
  set encounters(covariant ListBuilder<MeExportEncounter>? encounters) =>
      _$this._encounters = encounters;

  String? _id;
  String? get id => _$this._id;
  set id(covariant String? id) => _$this._id = id;

  String? _ownerId;
  String? get ownerId => _$this._ownerId;
  set ownerId(covariant String? ownerId) => _$this._ownerId = ownerId;

  String? _name;
  String? get name => _$this._name;
  set name(covariant String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(covariant String? description) =>
      _$this._description = description;

  GameSessionStatus? _status;
  GameSessionStatus? get status => _$this._status;
  set status(covariant GameSessionStatus? status) => _$this._status = status;

  int? _dpCount;
  int? get dpCount => _$this._dpCount;
  set dpCount(covariant int? dpCount) => _$this._dpCount = dpCount;

  ListBuilder<String>? _characterIds;
  ListBuilder<String> get characterIds =>
      _$this._characterIds ??= ListBuilder<String>();
  set characterIds(covariant ListBuilder<String>? characterIds) =>
      _$this._characterIds = characterIds;

  String? _shipId;
  String? get shipId => _$this._shipId;
  set shipId(covariant String? shipId) => _$this._shipId = shipId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(covariant DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(covariant DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  MeExportGameSessionBuilder() {
    MeExportGameSession._defaults(this);
  }

  MeExportGameSessionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _encounters = $v.encounters.toBuilder();
      _id = $v.id;
      _ownerId = $v.ownerId;
      _name = $v.name;
      _description = $v.description;
      _status = $v.status;
      _dpCount = $v.dpCount;
      _characterIds = $v.characterIds.toBuilder();
      _shipId = $v.shipId;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant MeExportGameSession other) {
    _$v = other as _$MeExportGameSession;
  }

  @override
  void update(void Function(MeExportGameSessionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeExportGameSession build() => _build();

  _$MeExportGameSession _build() {
    _$MeExportGameSession _$result;
    try {
      _$result = _$v ??
          _$MeExportGameSession._(
            encounters: encounters.build(),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'MeExportGameSession', 'id'),
            ownerId: BuiltValueNullFieldError.checkNotNull(
                ownerId, r'MeExportGameSession', 'ownerId'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'MeExportGameSession', 'name'),
            description: description,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'MeExportGameSession', 'status'),
            dpCount: BuiltValueNullFieldError.checkNotNull(
                dpCount, r'MeExportGameSession', 'dpCount'),
            characterIds: characterIds.build(),
            shipId: shipId,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'MeExportGameSession', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'MeExportGameSession', 'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'encounters';
        encounters.build();

        _$failedField = 'characterIds';
        characterIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MeExportGameSession', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
