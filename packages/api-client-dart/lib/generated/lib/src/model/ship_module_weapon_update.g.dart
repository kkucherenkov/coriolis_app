// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_module_weapon_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ShipModuleWeaponUpdateSlotEnum _$shipModuleWeaponUpdateSlotEnum_WEAPON =
    const ShipModuleWeaponUpdateSlotEnum._('WEAPON');

ShipModuleWeaponUpdateSlotEnum _$shipModuleWeaponUpdateSlotEnumValueOf(
    String name) {
  switch (name) {
    case 'WEAPON':
      return _$shipModuleWeaponUpdateSlotEnum_WEAPON;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ShipModuleWeaponUpdateSlotEnum>
    _$shipModuleWeaponUpdateSlotEnumValues = BuiltSet<
        ShipModuleWeaponUpdateSlotEnum>(const <ShipModuleWeaponUpdateSlotEnum>[
  _$shipModuleWeaponUpdateSlotEnum_WEAPON,
]);

Serializer<ShipModuleWeaponUpdateSlotEnum>
    _$shipModuleWeaponUpdateSlotEnumSerializer =
    _$ShipModuleWeaponUpdateSlotEnumSerializer();

class _$ShipModuleWeaponUpdateSlotEnumSerializer
    implements PrimitiveSerializer<ShipModuleWeaponUpdateSlotEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'WEAPON': 'WEAPON',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'WEAPON': 'WEAPON',
  };

  @override
  final Iterable<Type> types = const <Type>[ShipModuleWeaponUpdateSlotEnum];
  @override
  final String wireName = 'ShipModuleWeaponUpdateSlotEnum';

  @override
  Object serialize(
          Serializers serializers, ShipModuleWeaponUpdateSlotEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ShipModuleWeaponUpdateSlotEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ShipModuleWeaponUpdateSlotEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ShipModuleWeaponUpdate extends ShipModuleWeaponUpdate {
  @override
  final ShipModuleWeaponUpdateSlotEnum? slot;
  @override
  final String? name;
  @override
  final int? energyUse;
  @override
  final int? weaponBonus;
  @override
  final ShipWeaponRange? weaponRange;
  @override
  final int? weaponDamage;
  @override
  final int? weaponCritThreshold;
  @override
  final String? notes;

  factory _$ShipModuleWeaponUpdate(
          [void Function(ShipModuleWeaponUpdateBuilder)? updates]) =>
      (ShipModuleWeaponUpdateBuilder()..update(updates))._build();

  _$ShipModuleWeaponUpdate._(
      {this.slot,
      this.name,
      this.energyUse,
      this.weaponBonus,
      this.weaponRange,
      this.weaponDamage,
      this.weaponCritThreshold,
      this.notes})
      : super._();
  @override
  ShipModuleWeaponUpdate rebuild(
          void Function(ShipModuleWeaponUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipModuleWeaponUpdateBuilder toBuilder() =>
      ShipModuleWeaponUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipModuleWeaponUpdate &&
        slot == other.slot &&
        name == other.name &&
        energyUse == other.energyUse &&
        weaponBonus == other.weaponBonus &&
        weaponRange == other.weaponRange &&
        weaponDamage == other.weaponDamage &&
        weaponCritThreshold == other.weaponCritThreshold &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, slot.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, energyUse.hashCode);
    _$hash = $jc(_$hash, weaponBonus.hashCode);
    _$hash = $jc(_$hash, weaponRange.hashCode);
    _$hash = $jc(_$hash, weaponDamage.hashCode);
    _$hash = $jc(_$hash, weaponCritThreshold.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShipModuleWeaponUpdate')
          ..add('slot', slot)
          ..add('name', name)
          ..add('energyUse', energyUse)
          ..add('weaponBonus', weaponBonus)
          ..add('weaponRange', weaponRange)
          ..add('weaponDamage', weaponDamage)
          ..add('weaponCritThreshold', weaponCritThreshold)
          ..add('notes', notes))
        .toString();
  }
}

class ShipModuleWeaponUpdateBuilder
    implements Builder<ShipModuleWeaponUpdate, ShipModuleWeaponUpdateBuilder> {
  _$ShipModuleWeaponUpdate? _$v;

  ShipModuleWeaponUpdateSlotEnum? _slot;
  ShipModuleWeaponUpdateSlotEnum? get slot => _$this._slot;
  set slot(ShipModuleWeaponUpdateSlotEnum? slot) => _$this._slot = slot;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _energyUse;
  int? get energyUse => _$this._energyUse;
  set energyUse(int? energyUse) => _$this._energyUse = energyUse;

  int? _weaponBonus;
  int? get weaponBonus => _$this._weaponBonus;
  set weaponBonus(int? weaponBonus) => _$this._weaponBonus = weaponBonus;

  ShipWeaponRange? _weaponRange;
  ShipWeaponRange? get weaponRange => _$this._weaponRange;
  set weaponRange(ShipWeaponRange? weaponRange) =>
      _$this._weaponRange = weaponRange;

  int? _weaponDamage;
  int? get weaponDamage => _$this._weaponDamage;
  set weaponDamage(int? weaponDamage) => _$this._weaponDamage = weaponDamage;

  int? _weaponCritThreshold;
  int? get weaponCritThreshold => _$this._weaponCritThreshold;
  set weaponCritThreshold(int? weaponCritThreshold) =>
      _$this._weaponCritThreshold = weaponCritThreshold;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  ShipModuleWeaponUpdateBuilder() {
    ShipModuleWeaponUpdate._defaults(this);
  }

  ShipModuleWeaponUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _slot = $v.slot;
      _name = $v.name;
      _energyUse = $v.energyUse;
      _weaponBonus = $v.weaponBonus;
      _weaponRange = $v.weaponRange;
      _weaponDamage = $v.weaponDamage;
      _weaponCritThreshold = $v.weaponCritThreshold;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShipModuleWeaponUpdate other) {
    _$v = other as _$ShipModuleWeaponUpdate;
  }

  @override
  void update(void Function(ShipModuleWeaponUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipModuleWeaponUpdate build() => _build();

  _$ShipModuleWeaponUpdate _build() {
    final _$result = _$v ??
        _$ShipModuleWeaponUpdate._(
          slot: slot,
          name: name,
          energyUse: energyUse,
          weaponBonus: weaponBonus,
          weaponRange: weaponRange,
          weaponDamage: weaponDamage,
          weaponCritThreshold: weaponCritThreshold,
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
