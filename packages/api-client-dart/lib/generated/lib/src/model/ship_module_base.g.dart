// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_module_base.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

abstract class ShipModuleBaseBuilder {
  void replace(ShipModuleBase other);
  void update(void Function(ShipModuleBaseBuilder) updates);
  String? get id;
  set id(String? id);

  ShipModuleSlot? get slot;
  set slot(ShipModuleSlot? slot);

  String? get name;
  set name(String? name);

  int? get energyUse;
  set energyUse(int? energyUse);

  String? get notes;
  set notes(String? notes);
}

class _$$ShipModuleBase extends $ShipModuleBase {
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

  factory _$$ShipModuleBase([void Function($ShipModuleBaseBuilder)? updates]) =>
      (new $ShipModuleBaseBuilder()..update(updates))._build();

  _$$ShipModuleBase._(
      {required this.id,
      required this.slot,
      required this.name,
      required this.energyUse,
      this.notes})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(id, r'$ShipModuleBase', 'id');
    BuiltValueNullFieldError.checkNotNull(slot, r'$ShipModuleBase', 'slot');
    BuiltValueNullFieldError.checkNotNull(name, r'$ShipModuleBase', 'name');
    BuiltValueNullFieldError.checkNotNull(
        energyUse, r'$ShipModuleBase', 'energyUse');
  }

  @override
  $ShipModuleBase rebuild(void Function($ShipModuleBaseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  $ShipModuleBaseBuilder toBuilder() =>
      new $ShipModuleBaseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is $ShipModuleBase &&
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
    return (newBuiltValueToStringHelper(r'$ShipModuleBase')
          ..add('id', id)
          ..add('slot', slot)
          ..add('name', name)
          ..add('energyUse', energyUse)
          ..add('notes', notes))
        .toString();
  }
}

class $ShipModuleBaseBuilder
    implements
        Builder<$ShipModuleBase, $ShipModuleBaseBuilder>,
        ShipModuleBaseBuilder {
  _$$ShipModuleBase? _$v;

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

  $ShipModuleBaseBuilder() {
    $ShipModuleBase._defaults(this);
  }

  $ShipModuleBaseBuilder get _$this {
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
  void replace(covariant $ShipModuleBase other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$$ShipModuleBase;
  }

  @override
  void update(void Function($ShipModuleBaseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  $ShipModuleBase build() => _build();

  _$$ShipModuleBase _build() {
    final _$result = _$v ??
        new _$$ShipModuleBase._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'$ShipModuleBase', 'id'),
            slot: BuiltValueNullFieldError.checkNotNull(
                slot, r'$ShipModuleBase', 'slot'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'$ShipModuleBase', 'name'),
            energyUse: BuiltValueNullFieldError.checkNotNull(
                energyUse, r'$ShipModuleBase', 'energyUse'),
            notes: notes);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
