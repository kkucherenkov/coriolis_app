// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_create_energy.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShipCreateEnergy extends ShipCreateEnergy {
  @override
  final int? current;
  @override
  final int? max;

  factory _$ShipCreateEnergy(
          [void Function(ShipCreateEnergyBuilder)? updates]) =>
      (ShipCreateEnergyBuilder()..update(updates))._build();

  _$ShipCreateEnergy._({this.current, this.max}) : super._();
  @override
  ShipCreateEnergy rebuild(void Function(ShipCreateEnergyBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipCreateEnergyBuilder toBuilder() =>
      ShipCreateEnergyBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipCreateEnergy &&
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
    return (newBuiltValueToStringHelper(r'ShipCreateEnergy')
          ..add('current', current)
          ..add('max', max))
        .toString();
  }
}

class ShipCreateEnergyBuilder
    implements Builder<ShipCreateEnergy, ShipCreateEnergyBuilder> {
  _$ShipCreateEnergy? _$v;

  int? _current;
  int? get current => _$this._current;
  set current(int? current) => _$this._current = current;

  int? _max;
  int? get max => _$this._max;
  set max(int? max) => _$this._max = max;

  ShipCreateEnergyBuilder() {
    ShipCreateEnergy._defaults(this);
  }

  ShipCreateEnergyBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _current = $v.current;
      _max = $v.max;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShipCreateEnergy other) {
    _$v = other as _$ShipCreateEnergy;
  }

  @override
  void update(void Function(ShipCreateEnergyBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipCreateEnergy build() => _build();

  _$ShipCreateEnergy _build() {
    final _$result = _$v ??
        _$ShipCreateEnergy._(
          current: current,
          max: max,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
