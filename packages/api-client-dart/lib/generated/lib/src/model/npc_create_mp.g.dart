// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'npc_create_mp.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NpcCreateMp extends NpcCreateMp {
  @override
  final int? current;
  @override
  final int? max;

  factory _$NpcCreateMp([void Function(NpcCreateMpBuilder)? updates]) =>
      (NpcCreateMpBuilder()..update(updates))._build();

  _$NpcCreateMp._({this.current, this.max}) : super._();
  @override
  NpcCreateMp rebuild(void Function(NpcCreateMpBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NpcCreateMpBuilder toBuilder() => NpcCreateMpBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NpcCreateMp && current == other.current && max == other.max;
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
    return (newBuiltValueToStringHelper(r'NpcCreateMp')
          ..add('current', current)
          ..add('max', max))
        .toString();
  }
}

class NpcCreateMpBuilder implements Builder<NpcCreateMp, NpcCreateMpBuilder> {
  _$NpcCreateMp? _$v;

  int? _current;
  int? get current => _$this._current;
  set current(int? current) => _$this._current = current;

  int? _max;
  int? get max => _$this._max;
  set max(int? max) => _$this._max = max;

  NpcCreateMpBuilder() {
    NpcCreateMp._defaults(this);
  }

  NpcCreateMpBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _current = $v.current;
      _max = $v.max;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NpcCreateMp other) {
    _$v = other as _$NpcCreateMp;
  }

  @override
  void update(void Function(NpcCreateMpBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NpcCreateMp build() => _build();

  _$NpcCreateMp _build() {
    final _$result = _$v ??
        _$NpcCreateMp._(
          current: current,
          max: max,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
