// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_membership_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MyMembershipSummary extends MyMembershipSummary {
  @override
  final String membershipId;
  @override
  final String gameSessionId;
  @override
  final String sessionName;
  @override
  final GameSessionMemberRole role;
  @override
  final String? characterId;
  @override
  final String? characterName;
  @override
  final DateTime joinedAt;

  factory _$MyMembershipSummary(
          [void Function(MyMembershipSummaryBuilder)? updates]) =>
      (MyMembershipSummaryBuilder()..update(updates))._build();

  _$MyMembershipSummary._(
      {required this.membershipId,
      required this.gameSessionId,
      required this.sessionName,
      required this.role,
      this.characterId,
      this.characterName,
      required this.joinedAt})
      : super._();
  @override
  MyMembershipSummary rebuild(
          void Function(MyMembershipSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MyMembershipSummaryBuilder toBuilder() =>
      MyMembershipSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MyMembershipSummary &&
        membershipId == other.membershipId &&
        gameSessionId == other.gameSessionId &&
        sessionName == other.sessionName &&
        role == other.role &&
        characterId == other.characterId &&
        characterName == other.characterName &&
        joinedAt == other.joinedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, membershipId.hashCode);
    _$hash = $jc(_$hash, gameSessionId.hashCode);
    _$hash = $jc(_$hash, sessionName.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, characterId.hashCode);
    _$hash = $jc(_$hash, characterName.hashCode);
    _$hash = $jc(_$hash, joinedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MyMembershipSummary')
          ..add('membershipId', membershipId)
          ..add('gameSessionId', gameSessionId)
          ..add('sessionName', sessionName)
          ..add('role', role)
          ..add('characterId', characterId)
          ..add('characterName', characterName)
          ..add('joinedAt', joinedAt))
        .toString();
  }
}

class MyMembershipSummaryBuilder
    implements Builder<MyMembershipSummary, MyMembershipSummaryBuilder> {
  _$MyMembershipSummary? _$v;

  String? _membershipId;
  String? get membershipId => _$this._membershipId;
  set membershipId(String? membershipId) => _$this._membershipId = membershipId;

  String? _gameSessionId;
  String? get gameSessionId => _$this._gameSessionId;
  set gameSessionId(String? gameSessionId) =>
      _$this._gameSessionId = gameSessionId;

  String? _sessionName;
  String? get sessionName => _$this._sessionName;
  set sessionName(String? sessionName) => _$this._sessionName = sessionName;

  GameSessionMemberRole? _role;
  GameSessionMemberRole? get role => _$this._role;
  set role(GameSessionMemberRole? role) => _$this._role = role;

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

  MyMembershipSummaryBuilder() {
    MyMembershipSummary._defaults(this);
  }

  MyMembershipSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _membershipId = $v.membershipId;
      _gameSessionId = $v.gameSessionId;
      _sessionName = $v.sessionName;
      _role = $v.role;
      _characterId = $v.characterId;
      _characterName = $v.characterName;
      _joinedAt = $v.joinedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MyMembershipSummary other) {
    _$v = other as _$MyMembershipSummary;
  }

  @override
  void update(void Function(MyMembershipSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MyMembershipSummary build() => _build();

  _$MyMembershipSummary _build() {
    final _$result = _$v ??
        _$MyMembershipSummary._(
          membershipId: BuiltValueNullFieldError.checkNotNull(
              membershipId, r'MyMembershipSummary', 'membershipId'),
          gameSessionId: BuiltValueNullFieldError.checkNotNull(
              gameSessionId, r'MyMembershipSummary', 'gameSessionId'),
          sessionName: BuiltValueNullFieldError.checkNotNull(
              sessionName, r'MyMembershipSummary', 'sessionName'),
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'MyMembershipSummary', 'role'),
          characterId: characterId,
          characterName: characterName,
          joinedAt: BuiltValueNullFieldError.checkNotNull(
              joinedAt, r'MyMembershipSummary', 'joinedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
