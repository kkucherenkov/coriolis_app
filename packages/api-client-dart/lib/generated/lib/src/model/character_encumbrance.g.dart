// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_encumbrance.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CharacterEncumbrance extends CharacterEncumbrance {
  @override
  final num current;
  @override
  final int max;

  factory _$CharacterEncumbrance(
          [void Function(CharacterEncumbranceBuilder)? updates]) =>
      (new CharacterEncumbranceBuilder()..update(updates))._build();

  _$CharacterEncumbrance._({required this.current, required this.max})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        current, r'CharacterEncumbrance', 'current');
    BuiltValueNullFieldError.checkNotNull(max, r'CharacterEncumbrance', 'max');
  }

  @override
  CharacterEncumbrance rebuild(
          void Function(CharacterEncumbranceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CharacterEncumbranceBuilder toBuilder() =>
      new CharacterEncumbranceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CharacterEncumbrance &&
        current == other.current &&
        max == other.max;
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
    return (newBuiltValueToStringHelper(r'CharacterEncumbrance')
          ..add('current', current)
          ..add('max', max))
        .toString();
  }
}

class CharacterEncumbranceBuilder
    implements Builder<CharacterEncumbrance, CharacterEncumbranceBuilder> {
  _$CharacterEncumbrance? _$v;

  num? _current;
  num? get current => _$this._current;
  set current(num? current) => _$this._current = current;

  int? _max;
  int? get max => _$this._max;
  set max(int? max) => _$this._max = max;

  CharacterEncumbranceBuilder() {
    CharacterEncumbrance._defaults(this);
  }

  CharacterEncumbranceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _current = $v.current;
      _max = $v.max;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CharacterEncumbrance other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$CharacterEncumbrance;
  }

  @override
  void update(void Function(CharacterEncumbranceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CharacterEncumbrance build() => _build();

  _$CharacterEncumbrance _build() {
    final _$result = _$v ??
        new _$CharacterEncumbrance._(
            current: BuiltValueNullFieldError.checkNotNull(
                current, r'CharacterEncumbrance', 'current'),
            max: BuiltValueNullFieldError.checkNotNull(
                max, r'CharacterEncumbrance', 'max'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
