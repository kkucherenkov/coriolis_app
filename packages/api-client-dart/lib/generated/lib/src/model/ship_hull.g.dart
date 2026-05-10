// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_hull.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShipHull extends ShipHull {
  @override
  final int current;
  @override
  final int max;

  factory _$ShipHull([void Function(ShipHullBuilder)? updates]) =>
      (ShipHullBuilder()..update(updates))._build();

  _$ShipHull._({required this.current, required this.max}) : super._();
  @override
  ShipHull rebuild(void Function(ShipHullBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipHullBuilder toBuilder() => ShipHullBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipHull && current == other.current && max == other.max;
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
    return (newBuiltValueToStringHelper(r'ShipHull')
          ..add('current', current)
          ..add('max', max))
        .toString();
  }
}

class ShipHullBuilder implements Builder<ShipHull, ShipHullBuilder> {
  _$ShipHull? _$v;

  int? _current;
  int? get current => _$this._current;
  set current(int? current) => _$this._current = current;

  int? _max;
  int? get max => _$this._max;
  set max(int? max) => _$this._max = max;

  ShipHullBuilder() {
    ShipHull._defaults(this);
  }

  ShipHullBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _current = $v.current;
      _max = $v.max;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShipHull other) {
    _$v = other as _$ShipHull;
  }

  @override
  void update(void Function(ShipHullBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipHull build() => _build();

  _$ShipHull _build() {
    final _$result =
        _$v ??
        _$ShipHull._(
          current: BuiltValueNullFieldError.checkNotNull(
            current,
            r'ShipHull',
            'current',
          ),
          max: BuiltValueNullFieldError.checkNotNull(max, r'ShipHull', 'max'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
