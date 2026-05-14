// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_create_hull.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShipCreateHull extends ShipCreateHull {
  @override
  final int? current;
  @override
  final int? max;

  factory _$ShipCreateHull([void Function(ShipCreateHullBuilder)? updates]) =>
      (ShipCreateHullBuilder()..update(updates))._build();

  _$ShipCreateHull._({this.current, this.max}) : super._();
  @override
  ShipCreateHull rebuild(void Function(ShipCreateHullBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipCreateHullBuilder toBuilder() => ShipCreateHullBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipCreateHull &&
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
    return (newBuiltValueToStringHelper(r'ShipCreateHull')
          ..add('current', current)
          ..add('max', max))
        .toString();
  }
}

class ShipCreateHullBuilder
    implements Builder<ShipCreateHull, ShipCreateHullBuilder> {
  _$ShipCreateHull? _$v;

  int? _current;
  int? get current => _$this._current;
  set current(int? current) => _$this._current = current;

  int? _max;
  int? get max => _$this._max;
  set max(int? max) => _$this._max = max;

  ShipCreateHullBuilder() {
    ShipCreateHull._defaults(this);
  }

  ShipCreateHullBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _current = $v.current;
      _max = $v.max;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShipCreateHull other) {
    _$v = other as _$ShipCreateHull;
  }

  @override
  void update(void Function(ShipCreateHullBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipCreateHull build() => _build();

  _$ShipCreateHull _build() {
    final _$result = _$v ??
        _$ShipCreateHull._(
          current: current,
          max: max,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
