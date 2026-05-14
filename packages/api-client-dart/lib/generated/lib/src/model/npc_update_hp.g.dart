// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'npc_update_hp.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NpcUpdateHp extends NpcUpdateHp {
  @override
  final int? current;
  @override
  final int? max;

  factory _$NpcUpdateHp([void Function(NpcUpdateHpBuilder)? updates]) =>
      (NpcUpdateHpBuilder()..update(updates))._build();

  _$NpcUpdateHp._({this.current, this.max}) : super._();
  @override
  NpcUpdateHp rebuild(void Function(NpcUpdateHpBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NpcUpdateHpBuilder toBuilder() => NpcUpdateHpBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NpcUpdateHp && current == other.current && max == other.max;
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
    return (newBuiltValueToStringHelper(r'NpcUpdateHp')
          ..add('current', current)
          ..add('max', max))
        .toString();
  }
}

class NpcUpdateHpBuilder implements Builder<NpcUpdateHp, NpcUpdateHpBuilder> {
  _$NpcUpdateHp? _$v;

  int? _current;
  int? get current => _$this._current;
  set current(int? current) => _$this._current = current;

  int? _max;
  int? get max => _$this._max;
  set max(int? max) => _$this._max = max;

  NpcUpdateHpBuilder() {
    NpcUpdateHp._defaults(this);
  }

  NpcUpdateHpBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _current = $v.current;
      _max = $v.max;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NpcUpdateHp other) {
    _$v = other as _$NpcUpdateHp;
  }

  @override
  void update(void Function(NpcUpdateHpBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NpcUpdateHp build() => _build();

  _$NpcUpdateHp _build() {
    final _$result = _$v ??
        _$NpcUpdateHp._(
          current: current,
          max: max,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
