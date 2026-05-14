// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_link_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShareLinkCreate extends ShareLinkCreate {
  @override
  final bool? includeGmNotes;
  @override
  final DateTime? expiresAt;
  @override
  final String? label;

  factory _$ShareLinkCreate([void Function(ShareLinkCreateBuilder)? updates]) =>
      (ShareLinkCreateBuilder()..update(updates))._build();

  _$ShareLinkCreate._({this.includeGmNotes, this.expiresAt, this.label})
      : super._();
  @override
  ShareLinkCreate rebuild(void Function(ShareLinkCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShareLinkCreateBuilder toBuilder() => ShareLinkCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShareLinkCreate &&
        includeGmNotes == other.includeGmNotes &&
        expiresAt == other.expiresAt &&
        label == other.label;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, includeGmNotes.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShareLinkCreate')
          ..add('includeGmNotes', includeGmNotes)
          ..add('expiresAt', expiresAt)
          ..add('label', label))
        .toString();
  }
}

class ShareLinkCreateBuilder
    implements Builder<ShareLinkCreate, ShareLinkCreateBuilder> {
  _$ShareLinkCreate? _$v;

  bool? _includeGmNotes;
  bool? get includeGmNotes => _$this._includeGmNotes;
  set includeGmNotes(bool? includeGmNotes) =>
      _$this._includeGmNotes = includeGmNotes;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  ShareLinkCreateBuilder() {
    ShareLinkCreate._defaults(this);
  }

  ShareLinkCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _includeGmNotes = $v.includeGmNotes;
      _expiresAt = $v.expiresAt;
      _label = $v.label;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShareLinkCreate other) {
    _$v = other as _$ShareLinkCreate;
  }

  @override
  void update(void Function(ShareLinkCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShareLinkCreate build() => _build();

  _$ShareLinkCreate _build() {
    final _$result = _$v ??
        _$ShareLinkCreate._(
          includeGmNotes: includeGmNotes,
          expiresAt: expiresAt,
          label: label,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
