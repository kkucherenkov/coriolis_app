// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_mp.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CharacterMp extends CharacterMp {
  @override
  final int current;
  @override
  final int max;

  factory _$CharacterMp([void Function(CharacterMpBuilder)? updates]) =>
      (CharacterMpBuilder()..update(updates))._build();

  _$CharacterMp._({required this.current, required this.max}) : super._();
  @override
  CharacterMp rebuild(void Function(CharacterMpBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CharacterMpBuilder toBuilder() => CharacterMpBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CharacterMp && current == other.current && max == other.max;
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
    return (newBuiltValueToStringHelper(r'CharacterMp')
          ..add('current', current)
          ..add('max', max))
        .toString();
  }
}

class CharacterMpBuilder implements Builder<CharacterMp, CharacterMpBuilder> {
  _$CharacterMp? _$v;

  int? _current;
  int? get current => _$this._current;
  set current(int? current) => _$this._current = current;

  int? _max;
  int? get max => _$this._max;
  set max(int? max) => _$this._max = max;

  CharacterMpBuilder() {
    CharacterMp._defaults(this);
  }

  CharacterMpBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _current = $v.current;
      _max = $v.max;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CharacterMp other) {
    _$v = other as _$CharacterMp;
  }

  @override
  void update(void Function(CharacterMpBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CharacterMp build() => _build();

  _$CharacterMp _build() {
    final _$result = _$v ??
        _$CharacterMp._(
          current: BuiltValueNullFieldError.checkNotNull(
              current, r'CharacterMp', 'current'),
          max:
              BuiltValueNullFieldError.checkNotNull(max, r'CharacterMp', 'max'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
