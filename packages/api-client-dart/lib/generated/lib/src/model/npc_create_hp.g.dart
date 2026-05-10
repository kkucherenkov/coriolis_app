// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'npc_create_hp.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NpcCreateHp extends NpcCreateHp {
  @override
  final int? current;
  @override
  final int? max;

  factory _$NpcCreateHp([void Function(NpcCreateHpBuilder)? updates]) =>
      (new NpcCreateHpBuilder()..update(updates))._build();

  _$NpcCreateHp._({this.current, this.max}) : super._();

  @override
  NpcCreateHp rebuild(void Function(NpcCreateHpBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NpcCreateHpBuilder toBuilder() => new NpcCreateHpBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NpcCreateHp && current == other.current && max == other.max;
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
    return (newBuiltValueToStringHelper(r'NpcCreateHp')
          ..add('current', current)
          ..add('max', max))
        .toString();
  }
}

class NpcCreateHpBuilder implements Builder<NpcCreateHp, NpcCreateHpBuilder> {
  _$NpcCreateHp? _$v;

  int? _current;
  int? get current => _$this._current;
  set current(int? current) => _$this._current = current;

  int? _max;
  int? get max => _$this._max;
  set max(int? max) => _$this._max = max;

  NpcCreateHpBuilder() {
    NpcCreateHp._defaults(this);
  }

  NpcCreateHpBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _current = $v.current;
      _max = $v.max;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NpcCreateHp other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$NpcCreateHp;
  }

  @override
  void update(void Function(NpcCreateHpBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NpcCreateHp build() => _build();

  _$NpcCreateHp _build() {
    final _$result = _$v ?? new _$NpcCreateHp._(current: current, max: max);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
