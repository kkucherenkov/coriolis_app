// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session_membership.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GameSessionMembership extends GameSessionMembership {
  @override
  final String id;
  @override
  final String gameSessionId;
  @override
  final String userId;
  @override
  final GameSessionMemberRole role;
  @override
  final String? displayName;
  @override
  final String? characterId;
  @override
  final String? characterName;
  @override
  final DateTime joinedAt;
  @override
  final DateTime? leftAt;

  factory _$GameSessionMembership(
          [void Function(GameSessionMembershipBuilder)? updates]) =>
      (GameSessionMembershipBuilder()..update(updates))._build();

  _$GameSessionMembership._(
      {required this.id,
      required this.gameSessionId,
      required this.userId,
      required this.role,
      this.displayName,
      this.characterId,
      this.characterName,
      required this.joinedAt,
      this.leftAt})
      : super._();
  @override
  GameSessionMembership rebuild(
          void Function(GameSessionMembershipBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GameSessionMembershipBuilder toBuilder() =>
      GameSessionMembershipBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GameSessionMembership &&
        id == other.id &&
        gameSessionId == other.gameSessionId &&
        userId == other.userId &&
        role == other.role &&
        displayName == other.displayName &&
        characterId == other.characterId &&
        characterName == other.characterName &&
        joinedAt == other.joinedAt &&
        leftAt == other.leftAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, gameSessionId.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, characterId.hashCode);
    _$hash = $jc(_$hash, characterName.hashCode);
    _$hash = $jc(_$hash, joinedAt.hashCode);
    _$hash = $jc(_$hash, leftAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GameSessionMembership')
          ..add('id', id)
          ..add('gameSessionId', gameSessionId)
          ..add('userId', userId)
          ..add('role', role)
          ..add('displayName', displayName)
          ..add('characterId', characterId)
          ..add('characterName', characterName)
          ..add('joinedAt', joinedAt)
          ..add('leftAt', leftAt))
        .toString();
  }
}

class GameSessionMembershipBuilder
    implements Builder<GameSessionMembership, GameSessionMembershipBuilder> {
  _$GameSessionMembership? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _gameSessionId;
  String? get gameSessionId => _$this._gameSessionId;
  set gameSessionId(String? gameSessionId) =>
      _$this._gameSessionId = gameSessionId;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  GameSessionMemberRole? _role;
  GameSessionMemberRole? get role => _$this._role;
  set role(GameSessionMemberRole? role) => _$this._role = role;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _characterId;
  String? get characterId => _$this._characterId;
  set characterId(String? characterId) => _$this._characterId = characterId;

  String? _characterName;
  String? get characterName => _$this._characterName;
  set characterName(String? characterName) =>
      _$this._characterName = characterName;

  DateTime? _joinedAt;
  DateTime? get joinedAt => _$this._joinedAt;
  set joinedAt(DateTime? joinedAt) => _$this._joinedAt = joinedAt;

  DateTime? _leftAt;
  DateTime? get leftAt => _$this._leftAt;
  set leftAt(DateTime? leftAt) => _$this._leftAt = leftAt;

  GameSessionMembershipBuilder() {
    GameSessionMembership._defaults(this);
  }

  GameSessionMembershipBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _gameSessionId = $v.gameSessionId;
      _userId = $v.userId;
      _role = $v.role;
      _displayName = $v.displayName;
      _characterId = $v.characterId;
      _characterName = $v.characterName;
      _joinedAt = $v.joinedAt;
      _leftAt = $v.leftAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GameSessionMembership other) {
    _$v = other as _$GameSessionMembership;
  }

  @override
  void update(void Function(GameSessionMembershipBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GameSessionMembership build() => _build();

  _$GameSessionMembership _build() {
    final _$result = _$v ??
        _$GameSessionMembership._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GameSessionMembership', 'id'),
          gameSessionId: BuiltValueNullFieldError.checkNotNull(
              gameSessionId, r'GameSessionMembership', 'gameSessionId'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'GameSessionMembership', 'userId'),
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'GameSessionMembership', 'role'),
          displayName: displayName,
          characterId: characterId,
          characterName: characterName,
          joinedAt: BuiltValueNullFieldError.checkNotNull(
              joinedAt, r'GameSessionMembership', 'joinedAt'),
          leftAt: leftAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
