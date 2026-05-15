// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_rotated.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InviteRotated extends InviteRotated {
  @override
  final String url;
  @override
  final String token;
  @override
  final DateTime rotatedAt;

  factory _$InviteRotated([void Function(InviteRotatedBuilder)? updates]) =>
      (InviteRotatedBuilder()..update(updates))._build();

  _$InviteRotated._(
      {required this.url, required this.token, required this.rotatedAt})
      : super._();
  @override
  InviteRotated rebuild(void Function(InviteRotatedBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InviteRotatedBuilder toBuilder() => InviteRotatedBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InviteRotated &&
        url == other.url &&
        token == other.token &&
        rotatedAt == other.rotatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jc(_$hash, rotatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InviteRotated')
          ..add('url', url)
          ..add('token', token)
          ..add('rotatedAt', rotatedAt))
        .toString();
  }
}

class InviteRotatedBuilder
    implements Builder<InviteRotated, InviteRotatedBuilder> {
  _$InviteRotated? _$v;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  DateTime? _rotatedAt;
  DateTime? get rotatedAt => _$this._rotatedAt;
  set rotatedAt(DateTime? rotatedAt) => _$this._rotatedAt = rotatedAt;

  InviteRotatedBuilder() {
    InviteRotated._defaults(this);
  }

  InviteRotatedBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _url = $v.url;
      _token = $v.token;
      _rotatedAt = $v.rotatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InviteRotated other) {
    _$v = other as _$InviteRotated;
  }

  @override
  void update(void Function(InviteRotatedBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InviteRotated build() => _build();

  _$InviteRotated _build() {
    final _$result = _$v ??
        _$InviteRotated._(
          url: BuiltValueNullFieldError.checkNotNull(
              url, r'InviteRotated', 'url'),
          token: BuiltValueNullFieldError.checkNotNull(
              token, r'InviteRotated', 'token'),
          rotatedAt: BuiltValueNullFieldError.checkNotNull(
              rotatedAt, r'InviteRotated', 'rotatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
