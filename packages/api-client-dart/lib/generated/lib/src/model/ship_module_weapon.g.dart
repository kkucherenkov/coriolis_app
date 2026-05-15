// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_module_weapon.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ShipModuleWeaponSlotEnum _$shipModuleWeaponSlotEnum_WEAPON =
    const ShipModuleWeaponSlotEnum._('WEAPON');

ShipModuleWeaponSlotEnum _$shipModuleWeaponSlotEnumValueOf(String name) {
  switch (name) {
    case 'WEAPON':
      return _$shipModuleWeaponSlotEnum_WEAPON;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ShipModuleWeaponSlotEnum> _$shipModuleWeaponSlotEnumValues =
    BuiltSet<ShipModuleWeaponSlotEnum>(const <ShipModuleWeaponSlotEnum>[
  _$shipModuleWeaponSlotEnum_WEAPON,
]);

Serializer<ShipModuleWeaponSlotEnum> _$shipModuleWeaponSlotEnumSerializer =
    _$ShipModuleWeaponSlotEnumSerializer();

class _$ShipModuleWeaponSlotEnumSerializer
    implements PrimitiveSerializer<ShipModuleWeaponSlotEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'WEAPON': 'WEAPON',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'WEAPON': 'WEAPON',
  };

  @override
  final Iterable<Type> types = const <Type>[ShipModuleWeaponSlotEnum];
  @override
  final String wireName = 'ShipModuleWeaponSlotEnum';

  @override
  Object serialize(Serializers serializers, ShipModuleWeaponSlotEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ShipModuleWeaponSlotEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ShipModuleWeaponSlotEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ShipModuleWeapon extends ShipModuleWeapon {
  @override
  final ShipWeaponRange weaponRange;
  @override
  final int weaponBonus;
  @override
  final int weaponCritThreshold;
  @override
  final int weaponDamage;
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

  factory _$ShipModuleWeapon(
          [void Function(ShipModuleWeaponBuilder)? updates]) =>
      (ShipModuleWeaponBuilder()..update(updates))._build();

  _$ShipModuleWeapon._(
      {required this.weaponRange,
      required this.weaponBonus,
      required this.weaponCritThreshold,
      required this.weaponDamage,
      required this.id,
      required this.slot,
      required this.name,
      required this.energyUse,
      this.notes})
      : super._();
  @override
  ShipModuleWeapon rebuild(void Function(ShipModuleWeaponBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipModuleWeaponBuilder toBuilder() =>
      ShipModuleWeaponBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipModuleWeapon &&
        weaponRange == other.weaponRange &&
        weaponBonus == other.weaponBonus &&
        weaponCritThreshold == other.weaponCritThreshold &&
        weaponDamage == other.weaponDamage &&
        id == other.id &&
        slot == other.slot &&
        name == other.name &&
        energyUse == other.energyUse &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, weaponRange.hashCode);
    _$hash = $jc(_$hash, weaponBonus.hashCode);
    _$hash = $jc(_$hash, weaponCritThreshold.hashCode);
    _$hash = $jc(_$hash, weaponDamage.hashCode);
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
    return (newBuiltValueToStringHelper(r'ShipModuleWeapon')
          ..add('weaponRange', weaponRange)
          ..add('weaponBonus', weaponBonus)
          ..add('weaponCritThreshold', weaponCritThreshold)
          ..add('weaponDamage', weaponDamage)
          ..add('id', id)
          ..add('slot', slot)
          ..add('name', name)
          ..add('energyUse', energyUse)
          ..add('notes', notes))
        .toString();
  }
}

class ShipModuleWeaponBuilder
    implements
        Builder<ShipModuleWeapon, ShipModuleWeaponBuilder>,
        ShipModuleBaseBuilder {
  _$ShipModuleWeapon? _$v;

  ShipWeaponRange? _weaponRange;
  ShipWeaponRange? get weaponRange => _$this._weaponRange;
  set weaponRange(covariant ShipWeaponRange? weaponRange) =>
      _$this._weaponRange = weaponRange;

  int? _weaponBonus;
  int? get weaponBonus => _$this._weaponBonus;
  set weaponBonus(covariant int? weaponBonus) =>
      _$this._weaponBonus = weaponBonus;

  int? _weaponCritThreshold;
  int? get weaponCritThreshold => _$this._weaponCritThreshold;
  set weaponCritThreshold(covariant int? weaponCritThreshold) =>
      _$this._weaponCritThreshold = weaponCritThreshold;

  int? _weaponDamage;
  int? get weaponDamage => _$this._weaponDamage;
  set weaponDamage(covariant int? weaponDamage) =>
      _$this._weaponDamage = weaponDamage;

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

  ShipModuleWeaponBuilder() {
    ShipModuleWeapon._defaults(this);
  }

  ShipModuleWeaponBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _weaponRange = $v.weaponRange;
      _weaponBonus = $v.weaponBonus;
      _weaponCritThreshold = $v.weaponCritThreshold;
      _weaponDamage = $v.weaponDamage;
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
  void replace(covariant ShipModuleWeapon other) {
    _$v = other as _$ShipModuleWeapon;
  }

  @override
  void update(void Function(ShipModuleWeaponBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipModuleWeapon build() => _build();

  _$ShipModuleWeapon _build() {
    final _$result = _$v ??
        _$ShipModuleWeapon._(
          weaponRange: BuiltValueNullFieldError.checkNotNull(
              weaponRange, r'ShipModuleWeapon', 'weaponRange'),
          weaponBonus: BuiltValueNullFieldError.checkNotNull(
              weaponBonus, r'ShipModuleWeapon', 'weaponBonus'),
          weaponCritThreshold: BuiltValueNullFieldError.checkNotNull(
              weaponCritThreshold, r'ShipModuleWeapon', 'weaponCritThreshold'),
          weaponDamage: BuiltValueNullFieldError.checkNotNull(
              weaponDamage, r'ShipModuleWeapon', 'weaponDamage'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ShipModuleWeapon', 'id'),
          slot: BuiltValueNullFieldError.checkNotNull(
              slot, r'ShipModuleWeapon', 'slot'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'ShipModuleWeapon', 'name'),
          energyUse: BuiltValueNullFieldError.checkNotNull(
              energyUse, r'ShipModuleWeapon', 'energyUse'),
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
