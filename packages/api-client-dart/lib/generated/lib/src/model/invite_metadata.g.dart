// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_metadata.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InviteMetadata extends InviteMetadata {
  @override
  final bool active;
  @override
  final DateTime? rotatedAt;

  factory _$InviteMetadata([void Function(InviteMetadataBuilder)? updates]) =>
      (InviteMetadataBuilder()..update(updates))._build();

  _$InviteMetadata._({required this.active, this.rotatedAt}) : super._();
  @override
  InviteMetadata rebuild(void Function(InviteMetadataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InviteMetadataBuilder toBuilder() => InviteMetadataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InviteMetadata &&
        active == other.active &&
        rotatedAt == other.rotatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, active.hashCode);
    _$hash = $jc(_$hash, rotatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InviteMetadata')
          ..add('active', active)
          ..add('rotatedAt', rotatedAt))
        .toString();
  }
}

class InviteMetadataBuilder
    implements Builder<InviteMetadata, InviteMetadataBuilder> {
  _$InviteMetadata? _$v;

  bool? _active;
  bool? get active => _$this._active;
  set active(bool? active) => _$this._active = active;

  DateTime? _rotatedAt;
  DateTime? get rotatedAt => _$this._rotatedAt;
  set rotatedAt(DateTime? rotatedAt) => _$this._rotatedAt = rotatedAt;

  InviteMetadataBuilder() {
    InviteMetadata._defaults(this);
  }

  InviteMetadataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _active = $v.active;
      _rotatedAt = $v.rotatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InviteMetadata other) {
    _$v = other as _$InviteMetadata;
  }

  @override
  void update(void Function(InviteMetadataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InviteMetadata build() => _build();

  _$InviteMetadata _build() {
    final _$result = _$v ??
        _$InviteMetadata._(
          active: BuiltValueNullFieldError.checkNotNull(
              active, r'InviteMetadata', 'active'),
          rotatedAt: rotatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
