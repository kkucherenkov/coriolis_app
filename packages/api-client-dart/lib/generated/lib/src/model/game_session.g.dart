// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GameSession extends GameSession {
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

  factory _$GameSession([void Function(GameSessionBuilder)? updates]) =>
      (new GameSessionBuilder()..update(updates))._build();

  _$GameSession._(
      {required this.id,
      required this.ownerId,
      required this.name,
      this.description,
      required this.status,
      required this.dpCount,
      required this.characterIds,
      this.shipId,
      required this.createdAt,
      required this.updatedAt})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(id, r'GameSession', 'id');
    BuiltValueNullFieldError.checkNotNull(ownerId, r'GameSession', 'ownerId');
    BuiltValueNullFieldError.checkNotNull(name, r'GameSession', 'name');
    BuiltValueNullFieldError.checkNotNull(status, r'GameSession', 'status');
    BuiltValueNullFieldError.checkNotNull(dpCount, r'GameSession', 'dpCount');
    BuiltValueNullFieldError.checkNotNull(
        characterIds, r'GameSession', 'characterIds');
    BuiltValueNullFieldError.checkNotNull(
        createdAt, r'GameSession', 'createdAt');
    BuiltValueNullFieldError.checkNotNull(
        updatedAt, r'GameSession', 'updatedAt');
  }

  @override
  GameSession rebuild(void Function(GameSessionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GameSessionBuilder toBuilder() => new GameSessionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GameSession &&
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
    return (newBuiltValueToStringHelper(r'GameSession')
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

class GameSessionBuilder implements Builder<GameSession, GameSessionBuilder> {
  _$GameSession? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _ownerId;
  String? get ownerId => _$this._ownerId;
  set ownerId(String? ownerId) => _$this._ownerId = ownerId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  GameSessionStatus? _status;
  GameSessionStatus? get status => _$this._status;
  set status(GameSessionStatus? status) => _$this._status = status;

  int? _dpCount;
  int? get dpCount => _$this._dpCount;
  set dpCount(int? dpCount) => _$this._dpCount = dpCount;

  ListBuilder<String>? _characterIds;
  ListBuilder<String> get characterIds =>
      _$this._characterIds ??= new ListBuilder<String>();
  set characterIds(ListBuilder<String>? characterIds) =>
      _$this._characterIds = characterIds;

  String? _shipId;
  String? get shipId => _$this._shipId;
  set shipId(String? shipId) => _$this._shipId = shipId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  GameSessionBuilder() {
    GameSession._defaults(this);
  }

  GameSessionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
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
  void replace(GameSession other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GameSession;
  }

  @override
  void update(void Function(GameSessionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GameSession build() => _build();

  _$GameSession _build() {
    _$GameSession _$result;
    try {
      _$result = _$v ??
          new _$GameSession._(
              id: BuiltValueNullFieldError.checkNotNull(
                  id, r'GameSession', 'id'),
              ownerId: BuiltValueNullFieldError.checkNotNull(
                  ownerId, r'GameSession', 'ownerId'),
              name: BuiltValueNullFieldError.checkNotNull(
                  name, r'GameSession', 'name'),
              description: description,
              status: BuiltValueNullFieldError.checkNotNull(
                  status, r'GameSession', 'status'),
              dpCount: BuiltValueNullFieldError.checkNotNull(
                  dpCount, r'GameSession', 'dpCount'),
              characterIds: characterIds.build(),
              shipId: shipId,
              createdAt: BuiltValueNullFieldError.checkNotNull(
                  createdAt, r'GameSession', 'createdAt'),
              updatedAt: BuiltValueNullFieldError.checkNotNull(
                  updatedAt, r'GameSession', 'updatedAt'));
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'characterIds';
        characterIds.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GameSession', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
