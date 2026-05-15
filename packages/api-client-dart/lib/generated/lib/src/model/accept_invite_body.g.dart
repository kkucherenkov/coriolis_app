// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_invite_body.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AcceptInviteBody extends AcceptInviteBody {
  @override
  final String? characterId;

  factory _$AcceptInviteBody(
          [void Function(AcceptInviteBodyBuilder)? updates]) =>
      (AcceptInviteBodyBuilder()..update(updates))._build();

  _$AcceptInviteBody._({this.characterId}) : super._();
  @override
  AcceptInviteBody rebuild(void Function(AcceptInviteBodyBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AcceptInviteBodyBuilder toBuilder() =>
      AcceptInviteBodyBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AcceptInviteBody && characterId == other.characterId;
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
    return (newBuiltValueToStringHelper(r'AcceptInviteBody')
          ..add('characterId', characterId))
        .toString();
  }
}

class AcceptInviteBodyBuilder
    implements Builder<AcceptInviteBody, AcceptInviteBodyBuilder> {
  _$AcceptInviteBody? _$v;

  String? _characterId;
  String? get characterId => _$this._characterId;
  set characterId(String? characterId) => _$this._characterId = characterId;

  AcceptInviteBodyBuilder() {
    AcceptInviteBody._defaults(this);
  }

  AcceptInviteBodyBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _characterId = $v.characterId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AcceptInviteBody other) {
    _$v = other as _$AcceptInviteBody;
  }

  @override
  void update(void Function(AcceptInviteBodyBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AcceptInviteBody build() => _build();

  _$AcceptInviteBody _build() {
    final _$result = _$v ??
        _$AcceptInviteBody._(
          characterId: characterId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
