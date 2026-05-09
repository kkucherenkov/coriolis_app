// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_update_hull.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShipUpdateHull extends ShipUpdateHull {
  @override
  final int? current;
  @override
  final int? max;

  factory _$ShipUpdateHull([void Function(ShipUpdateHullBuilder)? updates]) =>
      (new ShipUpdateHullBuilder()..update(updates))._build();

  _$ShipUpdateHull._({this.current, this.max}) : super._();

  @override
  ShipUpdateHull rebuild(void Function(ShipUpdateHullBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipUpdateHullBuilder toBuilder() =>
      new ShipUpdateHullBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipUpdateHull &&
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
    return (newBuiltValueToStringHelper(r'ShipUpdateHull')
          ..add('current', current)
          ..add('max', max))
        .toString();
  }
}

class ShipUpdateHullBuilder
    implements Builder<ShipUpdateHull, ShipUpdateHullBuilder> {
  _$ShipUpdateHull? _$v;

  int? _current;
  int? get current => _$this._current;
  set current(int? current) => _$this._current = current;

  int? _max;
  int? get max => _$this._max;
  set max(int? max) => _$this._max = max;

  ShipUpdateHullBuilder() {
    ShipUpdateHull._defaults(this);
  }

  ShipUpdateHullBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _current = $v.current;
      _max = $v.max;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShipUpdateHull other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ShipUpdateHull;
  }

  @override
  void update(void Function(ShipUpdateHullBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipUpdateHull build() => _build();

  _$ShipUpdateHull _build() {
    final _$result = _$v ?? new _$ShipUpdateHull._(current: current, max: max);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
