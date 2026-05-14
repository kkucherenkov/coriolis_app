// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_module_other_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShipModuleOtherUpdate extends ShipModuleOtherUpdate {
  @override
  final ShipModuleSlot? slot;
  @override
  final String? name;
  @override
  final int? energyUse;
  @override
  final String? notes;

  factory _$ShipModuleOtherUpdate(
          [void Function(ShipModuleOtherUpdateBuilder)? updates]) =>
      (ShipModuleOtherUpdateBuilder()..update(updates))._build();

  _$ShipModuleOtherUpdate._({this.slot, this.name, this.energyUse, this.notes})
      : super._();
  @override
  ShipModuleOtherUpdate rebuild(
          void Function(ShipModuleOtherUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipModuleOtherUpdateBuilder toBuilder() =>
      ShipModuleOtherUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipModuleOtherUpdate &&
        slot == other.slot &&
        name == other.name &&
        energyUse == other.energyUse &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, slot.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, energyUse.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShipModuleOtherUpdate')
          ..add('slot', slot)
          ..add('name', name)
          ..add('energyUse', energyUse)
          ..add('notes', notes))
        .toString();
  }
}

class ShipModuleOtherUpdateBuilder
    implements Builder<ShipModuleOtherUpdate, ShipModuleOtherUpdateBuilder> {
  _$ShipModuleOtherUpdate? _$v;

  ShipModuleSlot? _slot;
  ShipModuleSlot? get slot => _$this._slot;
  set slot(ShipModuleSlot? slot) => _$this._slot = slot;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _energyUse;
  int? get energyUse => _$this._energyUse;
  set energyUse(int? energyUse) => _$this._energyUse = energyUse;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  ShipModuleOtherUpdateBuilder() {
    ShipModuleOtherUpdate._defaults(this);
  }

  ShipModuleOtherUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _slot = $v.slot;
      _name = $v.name;
      _energyUse = $v.energyUse;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShipModuleOtherUpdate other) {
    _$v = other as _$ShipModuleOtherUpdate;
  }

  @override
  void update(void Function(ShipModuleOtherUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipModuleOtherUpdate build() => _build();

  _$ShipModuleOtherUpdate _build() {
    final _$result = _$v ??
        _$ShipModuleOtherUpdate._(
          slot: slot,
          name: name,
          energyUse: energyUse,
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
