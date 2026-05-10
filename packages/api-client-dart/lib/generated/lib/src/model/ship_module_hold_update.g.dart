// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_module_hold_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ShipModuleHoldUpdateSlotEnum _$shipModuleHoldUpdateSlotEnum_HOLD =
    const ShipModuleHoldUpdateSlotEnum._('HOLD');

ShipModuleHoldUpdateSlotEnum _$shipModuleHoldUpdateSlotEnumValueOf(
  String name,
) {
  switch (name) {
    case 'HOLD':
      return _$shipModuleHoldUpdateSlotEnum_HOLD;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ShipModuleHoldUpdateSlotEnum>
_$shipModuleHoldUpdateSlotEnumValues = BuiltSet<ShipModuleHoldUpdateSlotEnum>(
  const <ShipModuleHoldUpdateSlotEnum>[_$shipModuleHoldUpdateSlotEnum_HOLD],
);

Serializer<ShipModuleHoldUpdateSlotEnum>
_$shipModuleHoldUpdateSlotEnumSerializer =
    _$ShipModuleHoldUpdateSlotEnumSerializer();

class _$ShipModuleHoldUpdateSlotEnumSerializer
    implements PrimitiveSerializer<ShipModuleHoldUpdateSlotEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'HOLD': 'HOLD',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'HOLD': 'HOLD',
  };

  @override
  final Iterable<Type> types = const <Type>[ShipModuleHoldUpdateSlotEnum];
  @override
  final String wireName = 'ShipModuleHoldUpdateSlotEnum';

  @override
  Object serialize(
    Serializers serializers,
    ShipModuleHoldUpdateSlotEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ShipModuleHoldUpdateSlotEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ShipModuleHoldUpdateSlotEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ShipModuleHoldUpdate extends ShipModuleHoldUpdate {
  @override
  final ShipModuleHoldUpdateSlotEnum? slot;
  @override
  final String? name;
  @override
  final int? energyUse;
  @override
  final int? cargoTons;
  @override
  final bool? concealed;
  @override
  final String? notes;

  factory _$ShipModuleHoldUpdate([
    void Function(ShipModuleHoldUpdateBuilder)? updates,
  ]) => (ShipModuleHoldUpdateBuilder()..update(updates))._build();

  _$ShipModuleHoldUpdate._({
    this.slot,
    this.name,
    this.energyUse,
    this.cargoTons,
    this.concealed,
    this.notes,
  }) : super._();
  @override
  ShipModuleHoldUpdate rebuild(
    void Function(ShipModuleHoldUpdateBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ShipModuleHoldUpdateBuilder toBuilder() =>
      ShipModuleHoldUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipModuleHoldUpdate &&
        slot == other.slot &&
        name == other.name &&
        energyUse == other.energyUse &&
        cargoTons == other.cargoTons &&
        concealed == other.concealed &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, slot.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, energyUse.hashCode);
    _$hash = $jc(_$hash, cargoTons.hashCode);
    _$hash = $jc(_$hash, concealed.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShipModuleHoldUpdate')
          ..add('slot', slot)
          ..add('name', name)
          ..add('energyUse', energyUse)
          ..add('cargoTons', cargoTons)
          ..add('concealed', concealed)
          ..add('notes', notes))
        .toString();
  }
}

class ShipModuleHoldUpdateBuilder
    implements Builder<ShipModuleHoldUpdate, ShipModuleHoldUpdateBuilder> {
  _$ShipModuleHoldUpdate? _$v;

  ShipModuleHoldUpdateSlotEnum? _slot;
  ShipModuleHoldUpdateSlotEnum? get slot => _$this._slot;
  set slot(ShipModuleHoldUpdateSlotEnum? slot) => _$this._slot = slot;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _energyUse;
  int? get energyUse => _$this._energyUse;
  set energyUse(int? energyUse) => _$this._energyUse = energyUse;

  int? _cargoTons;
  int? get cargoTons => _$this._cargoTons;
  set cargoTons(int? cargoTons) => _$this._cargoTons = cargoTons;

  bool? _concealed;
  bool? get concealed => _$this._concealed;
  set concealed(bool? concealed) => _$this._concealed = concealed;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  ShipModuleHoldUpdateBuilder() {
    ShipModuleHoldUpdate._defaults(this);
  }

  ShipModuleHoldUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _slot = $v.slot;
      _name = $v.name;
      _energyUse = $v.energyUse;
      _cargoTons = $v.cargoTons;
      _concealed = $v.concealed;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShipModuleHoldUpdate other) {
    _$v = other as _$ShipModuleHoldUpdate;
  }

  @override
  void update(void Function(ShipModuleHoldUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipModuleHoldUpdate build() => _build();

  _$ShipModuleHoldUpdate _build() {
    final _$result =
        _$v ??
        _$ShipModuleHoldUpdate._(
          slot: slot,
          name: name,
          energyUse: energyUse,
          cargoTons: cargoTons,
          concealed: concealed,
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
