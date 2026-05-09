// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_module_weapon_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ShipModuleWeaponCreateSlotEnum _$shipModuleWeaponCreateSlotEnum_WEAPON =
    const ShipModuleWeaponCreateSlotEnum._('WEAPON');

ShipModuleWeaponCreateSlotEnum _$shipModuleWeaponCreateSlotEnumValueOf(
    String name) {
  switch (name) {
    case 'WEAPON':
      return _$shipModuleWeaponCreateSlotEnum_WEAPON;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<ShipModuleWeaponCreateSlotEnum>
    _$shipModuleWeaponCreateSlotEnumValues = new BuiltSet<
        ShipModuleWeaponCreateSlotEnum>(const <ShipModuleWeaponCreateSlotEnum>[
  _$shipModuleWeaponCreateSlotEnum_WEAPON,
]);

Serializer<ShipModuleWeaponCreateSlotEnum>
    _$shipModuleWeaponCreateSlotEnumSerializer =
    new _$ShipModuleWeaponCreateSlotEnumSerializer();

class _$ShipModuleWeaponCreateSlotEnumSerializer
    implements PrimitiveSerializer<ShipModuleWeaponCreateSlotEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'WEAPON': 'WEAPON',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'WEAPON': 'WEAPON',
  };

  @override
  final Iterable<Type> types = const <Type>[ShipModuleWeaponCreateSlotEnum];
  @override
  final String wireName = 'ShipModuleWeaponCreateSlotEnum';

  @override
  Object serialize(
          Serializers serializers, ShipModuleWeaponCreateSlotEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ShipModuleWeaponCreateSlotEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ShipModuleWeaponCreateSlotEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ShipModuleWeaponCreate extends ShipModuleWeaponCreate {
  @override
  final ShipModuleWeaponCreateSlotEnum slot;
  @override
  final String name;
  @override
  final int energyUse;
  @override
  final int weaponBonus;
  @override
  final ShipWeaponRange weaponRange;
  @override
  final int weaponDamage;
  @override
  final int weaponCritThreshold;
  @override
  final String? notes;

  factory _$ShipModuleWeaponCreate(
          [void Function(ShipModuleWeaponCreateBuilder)? updates]) =>
      (new ShipModuleWeaponCreateBuilder()..update(updates))._build();

  _$ShipModuleWeaponCreate._(
      {required this.slot,
      required this.name,
      required this.energyUse,
      required this.weaponBonus,
      required this.weaponRange,
      required this.weaponDamage,
      required this.weaponCritThreshold,
      this.notes})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        slot, r'ShipModuleWeaponCreate', 'slot');
    BuiltValueNullFieldError.checkNotNull(
        name, r'ShipModuleWeaponCreate', 'name');
    BuiltValueNullFieldError.checkNotNull(
        energyUse, r'ShipModuleWeaponCreate', 'energyUse');
    BuiltValueNullFieldError.checkNotNull(
        weaponBonus, r'ShipModuleWeaponCreate', 'weaponBonus');
    BuiltValueNullFieldError.checkNotNull(
        weaponRange, r'ShipModuleWeaponCreate', 'weaponRange');
    BuiltValueNullFieldError.checkNotNull(
        weaponDamage, r'ShipModuleWeaponCreate', 'weaponDamage');
    BuiltValueNullFieldError.checkNotNull(
        weaponCritThreshold, r'ShipModuleWeaponCreate', 'weaponCritThreshold');
  }

  @override
  ShipModuleWeaponCreate rebuild(
          void Function(ShipModuleWeaponCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipModuleWeaponCreateBuilder toBuilder() =>
      new ShipModuleWeaponCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipModuleWeaponCreate &&
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
    return (newBuiltValueToStringHelper(r'ShipModuleWeaponCreate')
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

class ShipModuleWeaponCreateBuilder
    implements Builder<ShipModuleWeaponCreate, ShipModuleWeaponCreateBuilder> {
  _$ShipModuleWeaponCreate? _$v;

  ShipModuleWeaponCreateSlotEnum? _slot;
  ShipModuleWeaponCreateSlotEnum? get slot => _$this._slot;
  set slot(ShipModuleWeaponCreateSlotEnum? slot) => _$this._slot = slot;

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

  ShipModuleWeaponCreateBuilder() {
    ShipModuleWeaponCreate._defaults(this);
  }

  ShipModuleWeaponCreateBuilder get _$this {
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
  void replace(ShipModuleWeaponCreate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ShipModuleWeaponCreate;
  }

  @override
  void update(void Function(ShipModuleWeaponCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipModuleWeaponCreate build() => _build();

  _$ShipModuleWeaponCreate _build() {
    final _$result = _$v ??
        new _$ShipModuleWeaponCreate._(
            slot: BuiltValueNullFieldError.checkNotNull(
                slot, r'ShipModuleWeaponCreate', 'slot'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'ShipModuleWeaponCreate', 'name'),
            energyUse: BuiltValueNullFieldError.checkNotNull(
                energyUse, r'ShipModuleWeaponCreate', 'energyUse'),
            weaponBonus: BuiltValueNullFieldError.checkNotNull(
                weaponBonus, r'ShipModuleWeaponCreate', 'weaponBonus'),
            weaponRange: BuiltValueNullFieldError.checkNotNull(
                weaponRange, r'ShipModuleWeaponCreate', 'weaponRange'),
            weaponDamage: BuiltValueNullFieldError.checkNotNull(
                weaponDamage, r'ShipModuleWeaponCreate', 'weaponDamage'),
            weaponCritThreshold: BuiltValueNullFieldError.checkNotNull(
                weaponCritThreshold,
                r'ShipModuleWeaponCreate',
                'weaponCritThreshold'),
            notes: notes);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
