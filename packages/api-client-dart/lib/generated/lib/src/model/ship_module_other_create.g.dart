// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_module_other_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShipModuleOtherCreate extends ShipModuleOtherCreate {
  @override
  final ShipModuleSlot slot;
  @override
  final String name;
  @override
  final int energyUse;
  @override
  final String? notes;

  factory _$ShipModuleOtherCreate(
          [void Function(ShipModuleOtherCreateBuilder)? updates]) =>
      (ShipModuleOtherCreateBuilder()..update(updates))._build();

  _$ShipModuleOtherCreate._(
      {required this.slot,
      required this.name,
      required this.energyUse,
      this.notes})
      : super._();
  @override
  ShipModuleOtherCreate rebuild(
          void Function(ShipModuleOtherCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipModuleOtherCreateBuilder toBuilder() =>
      ShipModuleOtherCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipModuleOtherCreate &&
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
    return (newBuiltValueToStringHelper(r'ShipModuleOtherCreate')
          ..add('slot', slot)
          ..add('name', name)
          ..add('energyUse', energyUse)
          ..add('notes', notes))
        .toString();
  }
}

class ShipModuleOtherCreateBuilder
    implements Builder<ShipModuleOtherCreate, ShipModuleOtherCreateBuilder> {
  _$ShipModuleOtherCreate? _$v;

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

  ShipModuleOtherCreateBuilder() {
    ShipModuleOtherCreate._defaults(this);
  }

  ShipModuleOtherCreateBuilder get _$this {
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
  void replace(ShipModuleOtherCreate other) {
    _$v = other as _$ShipModuleOtherCreate;
  }

  @override
  void update(void Function(ShipModuleOtherCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipModuleOtherCreate build() => _build();

  _$ShipModuleOtherCreate _build() {
    final _$result = _$v ??
        _$ShipModuleOtherCreate._(
          slot: BuiltValueNullFieldError.checkNotNull(
              slot, r'ShipModuleOtherCreate', 'slot'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'ShipModuleOtherCreate', 'name'),
          energyUse: BuiltValueNullFieldError.checkNotNull(
              energyUse, r'ShipModuleOtherCreate', 'energyUse'),
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
