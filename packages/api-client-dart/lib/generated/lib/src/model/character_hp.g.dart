// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_hp.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CharacterHp extends CharacterHp {
  @override
  final int current;
  @override
  final int max;

  factory _$CharacterHp([void Function(CharacterHpBuilder)? updates]) =>
      (CharacterHpBuilder()..update(updates))._build();

  _$CharacterHp._({required this.current, required this.max}) : super._();
  @override
  CharacterHp rebuild(void Function(CharacterHpBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CharacterHpBuilder toBuilder() => CharacterHpBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CharacterHp && current == other.current && max == other.max;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, current.hashCode);
    _$hash = $jc(_$hash, max.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CharacterHp')
          ..add('current', current)
          ..add('max', max))
        .toString();
  }
}

class CharacterHpBuilder implements Builder<CharacterHp, CharacterHpBuilder> {
  _$CharacterHp? _$v;

  int? _current;
  int? get current => _$this._current;
  set current(int? current) => _$this._current = current;

  int? _max;
  int? get max => _$this._max;
  set max(int? max) => _$this._max = max;

  CharacterHpBuilder() {
    CharacterHp._defaults(this);
  }

  CharacterHpBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _current = $v.current;
      _max = $v.max;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CharacterHp other) {
    _$v = other as _$CharacterHp;
  }

  @override
  void update(void Function(CharacterHpBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CharacterHp build() => _build();

  _$CharacterHp _build() {
    final _$result = _$v ??
        _$CharacterHp._(
          current: BuiltValueNullFieldError.checkNotNull(
              current, r'CharacterHp', 'current'),
          max:
              BuiltValueNullFieldError.checkNotNull(max, r'CharacterHp', 'max'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
