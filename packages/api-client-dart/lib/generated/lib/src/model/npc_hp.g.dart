// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'npc_hp.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NpcHp extends NpcHp {
  @override
  final int current;
  @override
  final int max;

  factory _$NpcHp([void Function(NpcHpBuilder)? updates]) =>
      (NpcHpBuilder()..update(updates))._build();

  _$NpcHp._({required this.current, required this.max}) : super._();
  @override
  NpcHp rebuild(void Function(NpcHpBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NpcHpBuilder toBuilder() => NpcHpBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NpcHp && current == other.current && max == other.max;
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
    return (newBuiltValueToStringHelper(r'NpcHp')
          ..add('current', current)
          ..add('max', max))
        .toString();
  }
}

class NpcHpBuilder implements Builder<NpcHp, NpcHpBuilder> {
  _$NpcHp? _$v;

  int? _current;
  int? get current => _$this._current;
  set current(int? current) => _$this._current = current;

  int? _max;
  int? get max => _$this._max;
  set max(int? max) => _$this._max = max;

  NpcHpBuilder() {
    NpcHp._defaults(this);
  }

  NpcHpBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _current = $v.current;
      _max = $v.max;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NpcHp other) {
    _$v = other as _$NpcHp;
  }

  @override
  void update(void Function(NpcHpBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NpcHp build() => _build();

  _$NpcHp _build() {
    final _$result =
        _$v ??
        _$NpcHp._(
          current: BuiltValueNullFieldError.checkNotNull(
            current,
            r'NpcHp',
            'current',
          ),
          max: BuiltValueNullFieldError.checkNotNull(max, r'NpcHp', 'max'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
