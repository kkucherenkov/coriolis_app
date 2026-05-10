// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'npc_mp.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NpcMp extends NpcMp {
  @override
  final int current;
  @override
  final int max;

  factory _$NpcMp([void Function(NpcMpBuilder)? updates]) =>
      (NpcMpBuilder()..update(updates))._build();

  _$NpcMp._({required this.current, required this.max}) : super._();
  @override
  NpcMp rebuild(void Function(NpcMpBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NpcMpBuilder toBuilder() => NpcMpBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NpcMp && current == other.current && max == other.max;
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
    return (newBuiltValueToStringHelper(r'NpcMp')
          ..add('current', current)
          ..add('max', max))
        .toString();
  }
}

class NpcMpBuilder implements Builder<NpcMp, NpcMpBuilder> {
  _$NpcMp? _$v;

  int? _current;
  int? get current => _$this._current;
  set current(int? current) => _$this._current = current;

  int? _max;
  int? get max => _$this._max;
  set max(int? max) => _$this._max = max;

  NpcMpBuilder() {
    NpcMp._defaults(this);
  }

  NpcMpBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _current = $v.current;
      _max = $v.max;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NpcMp other) {
    _$v = other as _$NpcMp;
  }

  @override
  void update(void Function(NpcMpBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NpcMp build() => _build();

  _$NpcMp _build() {
    final _$result =
        _$v ??
        _$NpcMp._(
          current: BuiltValueNullFieldError.checkNotNull(
            current,
            r'NpcMp',
            'current',
          ),
          max: BuiltValueNullFieldError.checkNotNull(max, r'NpcMp', 'max'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
