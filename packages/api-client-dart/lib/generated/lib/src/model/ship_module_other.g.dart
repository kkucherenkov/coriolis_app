// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_module_other.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShipModuleOther extends ShipModuleOther {
  @override
  final String id;
  @override
  final ShipModuleSlot slot;
  @override
  final String name;
  @override
  final int energyUse;
  @override
  final String? notes;

  factory _$ShipModuleOther([void Function(ShipModuleOtherBuilder)? updates]) =>
      (new ShipModuleOtherBuilder()..update(updates))._build();

  _$ShipModuleOther._(
      {required this.id,
      required this.slot,
      required this.name,
      required this.energyUse,
      this.notes})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(id, r'ShipModuleOther', 'id');
    BuiltValueNullFieldError.checkNotNull(slot, r'ShipModuleOther', 'slot');
    BuiltValueNullFieldError.checkNotNull(name, r'ShipModuleOther', 'name');
    BuiltValueNullFieldError.checkNotNull(
        energyUse, r'ShipModuleOther', 'energyUse');
  }

  @override
  ShipModuleOther rebuild(void Function(ShipModuleOtherBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipModuleOtherBuilder toBuilder() =>
      new ShipModuleOtherBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipModuleOther &&
        id == other.id &&
        slot == other.slot &&
        name == other.name &&
        energyUse == other.energyUse &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, slot.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, energyUse.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShipModuleOther')
          ..add('id', id)
          ..add('slot', slot)
          ..add('name', name)
          ..add('energyUse', energyUse)
          ..add('notes', notes))
        .toString();
  }
}

class ShipModuleOtherBuilder
    implements
        Builder<ShipModuleOther, ShipModuleOtherBuilder>,
        ShipModuleBaseBuilder {
  _$ShipModuleOther? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(covariant String? id) => _$this._id = id;

  ShipModuleSlot? _slot;
  ShipModuleSlot? get slot => _$this._slot;
  set slot(covariant ShipModuleSlot? slot) => _$this._slot = slot;

  String? _name;
  String? get name => _$this._name;
  set name(covariant String? name) => _$this._name = name;

  int? _energyUse;
  int? get energyUse => _$this._energyUse;
  set energyUse(covariant int? energyUse) => _$this._energyUse = energyUse;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(covariant String? notes) => _$this._notes = notes;

  ShipModuleOtherBuilder() {
    ShipModuleOther._defaults(this);
  }

  ShipModuleOtherBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _slot = $v.slot;
      _name = $v.name;
      _energyUse = $v.energyUse;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant ShipModuleOther other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ShipModuleOther;
  }

  @override
  void update(void Function(ShipModuleOtherBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipModuleOther build() => _build();

  _$ShipModuleOther _build() {
    final _$result = _$v ??
        new _$ShipModuleOther._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'ShipModuleOther', 'id'),
            slot: BuiltValueNullFieldError.checkNotNull(
                slot, r'ShipModuleOther', 'slot'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'ShipModuleOther', 'name'),
            energyUse: BuiltValueNullFieldError.checkNotNull(
                energyUse, r'ShipModuleOther', 'energyUse'),
            notes: notes);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
