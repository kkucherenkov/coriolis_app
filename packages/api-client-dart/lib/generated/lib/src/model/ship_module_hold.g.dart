// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_module_hold.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ShipModuleHoldSlotEnum _$shipModuleHoldSlotEnum_HOLD =
    const ShipModuleHoldSlotEnum._('HOLD');

ShipModuleHoldSlotEnum _$shipModuleHoldSlotEnumValueOf(String name) {
  switch (name) {
    case 'HOLD':
      return _$shipModuleHoldSlotEnum_HOLD;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ShipModuleHoldSlotEnum> _$shipModuleHoldSlotEnumValues =
    BuiltSet<ShipModuleHoldSlotEnum>(const <ShipModuleHoldSlotEnum>[
  _$shipModuleHoldSlotEnum_HOLD,
]);

Serializer<ShipModuleHoldSlotEnum> _$shipModuleHoldSlotEnumSerializer =
    _$ShipModuleHoldSlotEnumSerializer();

class _$ShipModuleHoldSlotEnumSerializer
    implements PrimitiveSerializer<ShipModuleHoldSlotEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'HOLD': 'HOLD',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'HOLD': 'HOLD',
  };

  @override
  final Iterable<Type> types = const <Type>[ShipModuleHoldSlotEnum];
  @override
  final String wireName = 'ShipModuleHoldSlotEnum';

  @override
  Object serialize(Serializers serializers, ShipModuleHoldSlotEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ShipModuleHoldSlotEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ShipModuleHoldSlotEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ShipModuleHold extends ShipModuleHold {
  @override
  final int? cargoTons;
  @override
  final bool? concealed;
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

  factory _$ShipModuleHold([void Function(ShipModuleHoldBuilder)? updates]) =>
      (ShipModuleHoldBuilder()..update(updates))._build();

  _$ShipModuleHold._(
      {this.cargoTons,
      this.concealed,
      required this.id,
      required this.slot,
      required this.name,
      required this.energyUse,
      this.notes})
      : super._();
  @override
  ShipModuleHold rebuild(void Function(ShipModuleHoldBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipModuleHoldBuilder toBuilder() => ShipModuleHoldBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipModuleHold &&
        cargoTons == other.cargoTons &&
        concealed == other.concealed &&
        id == other.id &&
        slot == other.slot &&
        name == other.name &&
        energyUse == other.energyUse &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cargoTons.hashCode);
    _$hash = $jc(_$hash, concealed.hashCode);
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
    return (newBuiltValueToStringHelper(r'ShipModuleHold')
          ..add('cargoTons', cargoTons)
          ..add('concealed', concealed)
          ..add('id', id)
          ..add('slot', slot)
          ..add('name', name)
          ..add('energyUse', energyUse)
          ..add('notes', notes))
        .toString();
  }
}

class ShipModuleHoldBuilder
    implements
        Builder<ShipModuleHold, ShipModuleHoldBuilder>,
        ShipModuleBaseBuilder {
  _$ShipModuleHold? _$v;

  int? _cargoTons;
  int? get cargoTons => _$this._cargoTons;
  set cargoTons(covariant int? cargoTons) => _$this._cargoTons = cargoTons;

  bool? _concealed;
  bool? get concealed => _$this._concealed;
  set concealed(covariant bool? concealed) => _$this._concealed = concealed;

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

  ShipModuleHoldBuilder() {
    ShipModuleHold._defaults(this);
  }

  ShipModuleHoldBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cargoTons = $v.cargoTons;
      _concealed = $v.concealed;
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
  void replace(covariant ShipModuleHold other) {
    _$v = other as _$ShipModuleHold;
  }

  @override
  void update(void Function(ShipModuleHoldBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipModuleHold build() => _build();

  _$ShipModuleHold _build() {
    final _$result = _$v ??
        _$ShipModuleHold._(
          cargoTons: cargoTons,
          concealed: concealed,
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ShipModuleHold', 'id'),
          slot: BuiltValueNullFieldError.checkNotNull(
              slot, r'ShipModuleHold', 'slot'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'ShipModuleHold', 'name'),
          energyUse: BuiltValueNullFieldError.checkNotNull(
              energyUse, r'ShipModuleHold', 'energyUse'),
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
