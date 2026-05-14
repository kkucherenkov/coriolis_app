// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_energy.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShipEnergy extends ShipEnergy {
  @override
  final int current;
  @override
  final int max;

  factory _$ShipEnergy([void Function(ShipEnergyBuilder)? updates]) =>
      (ShipEnergyBuilder()..update(updates))._build();

  _$ShipEnergy._({required this.current, required this.max}) : super._();
  @override
  ShipEnergy rebuild(void Function(ShipEnergyBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipEnergyBuilder toBuilder() => ShipEnergyBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipEnergy && current == other.current && max == other.max;
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
    return (newBuiltValueToStringHelper(r'ShipEnergy')
          ..add('current', current)
          ..add('max', max))
        .toString();
  }
}

class ShipEnergyBuilder implements Builder<ShipEnergy, ShipEnergyBuilder> {
  _$ShipEnergy? _$v;

  int? _current;
  int? get current => _$this._current;
  set current(int? current) => _$this._current = current;

  int? _max;
  int? get max => _$this._max;
  set max(int? max) => _$this._max = max;

  ShipEnergyBuilder() {
    ShipEnergy._defaults(this);
  }

  ShipEnergyBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _current = $v.current;
      _max = $v.max;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShipEnergy other) {
    _$v = other as _$ShipEnergy;
  }

  @override
  void update(void Function(ShipEnergyBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipEnergy build() => _build();

  _$ShipEnergy _build() {
    final _$result = _$v ??
        _$ShipEnergy._(
          current: BuiltValueNullFieldError.checkNotNull(
              current, r'ShipEnergy', 'current'),
          max: BuiltValueNullFieldError.checkNotNull(max, r'ShipEnergy', 'max'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
