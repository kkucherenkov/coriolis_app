// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_invite_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AcceptInviteResponse extends AcceptInviteResponse {
  @override
  final GameSessionMembership membership;

  factory _$AcceptInviteResponse(
          [void Function(AcceptInviteResponseBuilder)? updates]) =>
      (AcceptInviteResponseBuilder()..update(updates))._build();

  _$AcceptInviteResponse._({required this.membership}) : super._();
  @override
  AcceptInviteResponse rebuild(
          void Function(AcceptInviteResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AcceptInviteResponseBuilder toBuilder() =>
      AcceptInviteResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AcceptInviteResponse && membership == other.membership;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, membership.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AcceptInviteResponse')
          ..add('membership', membership))
        .toString();
  }
}

class AcceptInviteResponseBuilder
    implements Builder<AcceptInviteResponse, AcceptInviteResponseBuilder> {
  _$AcceptInviteResponse? _$v;

  GameSessionMembershipBuilder? _membership;
  GameSessionMembershipBuilder get membership =>
      _$this._membership ??= GameSessionMembershipBuilder();
  set membership(GameSessionMembershipBuilder? membership) =>
      _$this._membership = membership;

  AcceptInviteResponseBuilder() {
    AcceptInviteResponse._defaults(this);
  }

  AcceptInviteResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _membership = $v.membership.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AcceptInviteResponse other) {
    _$v = other as _$AcceptInviteResponse;
  }

  @override
  void update(void Function(AcceptInviteResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AcceptInviteResponse build() => _build();

  _$AcceptInviteResponse _build() {
    _$AcceptInviteResponse _$result;
    try {
      _$result = _$v ??
          _$AcceptInviteResponse._(
            membership: membership.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'membership';
        membership.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AcceptInviteResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
