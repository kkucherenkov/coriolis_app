// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assign_character_to_session.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AssignCharacterToSession extends AssignCharacterToSession {
  @override
  final String characterId;

  factory _$AssignCharacterToSession(
          [void Function(AssignCharacterToSessionBuilder)? updates]) =>
      (new AssignCharacterToSessionBuilder()..update(updates))._build();

  _$AssignCharacterToSession._({required this.characterId}) : super._() {
    BuiltValueNullFieldError.checkNotNull(
        characterId, r'AssignCharacterToSession', 'characterId');
  }

  @override
  AssignCharacterToSession rebuild(
          void Function(AssignCharacterToSessionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AssignCharacterToSessionBuilder toBuilder() =>
      new AssignCharacterToSessionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AssignCharacterToSession &&
        characterId == other.characterId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, characterId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AssignCharacterToSession')
          ..add('characterId', characterId))
        .toString();
  }
}

class AssignCharacterToSessionBuilder
    implements
        Builder<AssignCharacterToSession, AssignCharacterToSessionBuilder> {
  _$AssignCharacterToSession? _$v;

  String? _characterId;
  String? get characterId => _$this._characterId;
  set characterId(String? characterId) => _$this._characterId = characterId;

  AssignCharacterToSessionBuilder() {
    AssignCharacterToSession._defaults(this);
  }

  AssignCharacterToSessionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _characterId = $v.characterId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AssignCharacterToSession other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$AssignCharacterToSession;
  }

  @override
  void update(void Function(AssignCharacterToSessionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AssignCharacterToSession build() => _build();

  _$AssignCharacterToSession _build() {
    final _$result = _$v ??
        new _$AssignCharacterToSession._(
            characterId: BuiltValueNullFieldError.checkNotNull(
                characterId, r'AssignCharacterToSession', 'characterId'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
