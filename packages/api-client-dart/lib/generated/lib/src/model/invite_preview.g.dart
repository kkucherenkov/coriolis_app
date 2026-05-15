// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_preview.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InvitePreview extends InvitePreview {
  @override
  final String sessionName;
  @override
  final String gmDisplayName;
  @override
  final bool alreadyJoined;

  factory _$InvitePreview([void Function(InvitePreviewBuilder)? updates]) =>
      (InvitePreviewBuilder()..update(updates))._build();

  _$InvitePreview._(
      {required this.sessionName,
      required this.gmDisplayName,
      required this.alreadyJoined})
      : super._();
  @override
  InvitePreview rebuild(void Function(InvitePreviewBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InvitePreviewBuilder toBuilder() => InvitePreviewBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InvitePreview &&
        sessionName == other.sessionName &&
        gmDisplayName == other.gmDisplayName &&
        alreadyJoined == other.alreadyJoined;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sessionName.hashCode);
    _$hash = $jc(_$hash, gmDisplayName.hashCode);
    _$hash = $jc(_$hash, alreadyJoined.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InvitePreview')
          ..add('sessionName', sessionName)
          ..add('gmDisplayName', gmDisplayName)
          ..add('alreadyJoined', alreadyJoined))
        .toString();
  }
}

class InvitePreviewBuilder
    implements Builder<InvitePreview, InvitePreviewBuilder> {
  _$InvitePreview? _$v;

  String? _sessionName;
  String? get sessionName => _$this._sessionName;
  set sessionName(String? sessionName) => _$this._sessionName = sessionName;

  String? _gmDisplayName;
  String? get gmDisplayName => _$this._gmDisplayName;
  set gmDisplayName(String? gmDisplayName) =>
      _$this._gmDisplayName = gmDisplayName;

  bool? _alreadyJoined;
  bool? get alreadyJoined => _$this._alreadyJoined;
  set alreadyJoined(bool? alreadyJoined) =>
      _$this._alreadyJoined = alreadyJoined;

  InvitePreviewBuilder() {
    InvitePreview._defaults(this);
  }

  InvitePreviewBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sessionName = $v.sessionName;
      _gmDisplayName = $v.gmDisplayName;
      _alreadyJoined = $v.alreadyJoined;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InvitePreview other) {
    _$v = other as _$InvitePreview;
  }

  @override
  void update(void Function(InvitePreviewBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InvitePreview build() => _build();

  _$InvitePreview _build() {
    final _$result = _$v ??
        _$InvitePreview._(
          sessionName: BuiltValueNullFieldError.checkNotNull(
              sessionName, r'InvitePreview', 'sessionName'),
          gmDisplayName: BuiltValueNullFieldError.checkNotNull(
              gmDisplayName, r'InvitePreview', 'gmDisplayName'),
          alreadyJoined: BuiltValueNullFieldError.checkNotNull(
              alreadyJoined, r'InvitePreview', 'alreadyJoined'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
