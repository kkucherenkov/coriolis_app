// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_create_hp.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CharacterCreateHp extends CharacterCreateHp {
  @override
  final int? current;

  factory _$CharacterCreateHp(
          [void Function(CharacterCreateHpBuilder)? updates]) =>
      (new CharacterCreateHpBuilder()..update(updates))._build();

  _$CharacterCreateHp._({this.current}) : super._();

  @override
  CharacterCreateHp rebuild(void Function(CharacterCreateHpBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CharacterCreateHpBuilder toBuilder() =>
      new CharacterCreateHpBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CharacterCreateHp && current == other.current;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, current.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CharacterCreateHp')
          ..add('current', current))
        .toString();
  }
}

class CharacterCreateHpBuilder
    implements Builder<CharacterCreateHp, CharacterCreateHpBuilder> {
  _$CharacterCreateHp? _$v;

  int? _current;
  int? get current => _$this._current;
  set current(int? current) => _$this._current = current;

  CharacterCreateHpBuilder() {
    CharacterCreateHp._defaults(this);
  }

  CharacterCreateHpBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _current = $v.current;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CharacterCreateHp other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$CharacterCreateHp;
  }

  @override
  void update(void Function(CharacterCreateHpBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CharacterCreateHp build() => _build();

  _$CharacterCreateHp _build() {
    final _$result = _$v ?? new _$CharacterCreateHp._(current: current);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
