// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_export_user.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MeExportUser extends MeExportUser {
  @override
  final String id;
  @override
  final String? displayName;

  factory _$MeExportUser([void Function(MeExportUserBuilder)? updates]) =>
      (MeExportUserBuilder()..update(updates))._build();

  _$MeExportUser._({required this.id, this.displayName}) : super._();
  @override
  MeExportUser rebuild(void Function(MeExportUserBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeExportUserBuilder toBuilder() => MeExportUserBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeExportUser &&
        id == other.id &&
        displayName == other.displayName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MeExportUser')
          ..add('id', id)
          ..add('displayName', displayName))
        .toString();
  }
}

class MeExportUserBuilder
    implements Builder<MeExportUser, MeExportUserBuilder> {
  _$MeExportUser? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  MeExportUserBuilder() {
    MeExportUser._defaults(this);
  }

  MeExportUserBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _displayName = $v.displayName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeExportUser other) {
    _$v = other as _$MeExportUser;
  }

  @override
  void update(void Function(MeExportUserBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeExportUser build() => _build();

  _$MeExportUser _build() {
    final _$result = _$v ??
        _$MeExportUser._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'MeExportUser', 'id'),
          displayName: displayName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
