// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_module_hold_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ShipModuleHoldCreateSlotEnum _$shipModuleHoldCreateSlotEnum_HOLD =
    const ShipModuleHoldCreateSlotEnum._('HOLD');

ShipModuleHoldCreateSlotEnum _$shipModuleHoldCreateSlotEnumValueOf(
  String name,
) {
  switch (name) {
    case 'HOLD':
      return _$shipModuleHoldCreateSlotEnum_HOLD;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ShipModuleHoldCreateSlotEnum>
_$shipModuleHoldCreateSlotEnumValues = BuiltSet<ShipModuleHoldCreateSlotEnum>(
  const <ShipModuleHoldCreateSlotEnum>[_$shipModuleHoldCreateSlotEnum_HOLD],
);

Serializer<ShipModuleHoldCreateSlotEnum>
_$shipModuleHoldCreateSlotEnumSerializer =
    _$ShipModuleHoldCreateSlotEnumSerializer();

class _$ShipModuleHoldCreateSlotEnumSerializer
    implements PrimitiveSerializer<ShipModuleHoldCreateSlotEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'HOLD': 'HOLD',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'HOLD': 'HOLD',
  };

  @override
  final Iterable<Type> types = const <Type>[ShipModuleHoldCreateSlotEnum];
  @override
  final String wireName = 'ShipModuleHoldCreateSlotEnum';

  @override
  Object serialize(
    Serializers serializers,
    ShipModuleHoldCreateSlotEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ShipModuleHoldCreateSlotEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ShipModuleHoldCreateSlotEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ShipModuleHoldCreate extends ShipModuleHoldCreate {
  @override
  final ShipModuleHoldCreateSlotEnum slot;
  @override
  final String name;
  @override
  final int energyUse;
  @override
  final int? cargoTons;
  @override
  final bool? concealed;
  @override
  final String? notes;

  factory _$ShipModuleHoldCreate([
    void Function(ShipModuleHoldCreateBuilder)? updates,
  ]) => (ShipModuleHoldCreateBuilder()..update(updates))._build();

  _$ShipModuleHoldCreate._({
    required this.slot,
    required this.name,
    required this.energyUse,
    this.cargoTons,
    this.concealed,
    this.notes,
  }) : super._();
  @override
  ShipModuleHoldCreate rebuild(
    void Function(ShipModuleHoldCreateBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ShipModuleHoldCreateBuilder toBuilder() =>
      ShipModuleHoldCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipModuleHoldCreate &&
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
    return (newBuiltValueToStringHelper(r'ShipModuleHoldCreate')
          ..add('slot', slot)
          ..add('name', name)
          ..add('energyUse', energyUse)
          ..add('cargoTons', cargoTons)
          ..add('concealed', concealed)
          ..add('notes', notes))
        .toString();
  }
}

class ShipModuleHoldCreateBuilder
    implements Builder<ShipModuleHoldCreate, ShipModuleHoldCreateBuilder> {
  _$ShipModuleHoldCreate? _$v;

  ShipModuleHoldCreateSlotEnum? _slot;
  ShipModuleHoldCreateSlotEnum? get slot => _$this._slot;
  set slot(ShipModuleHoldCreateSlotEnum? slot) => _$this._slot = slot;

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

  ShipModuleHoldCreateBuilder() {
    ShipModuleHoldCreate._defaults(this);
  }

  ShipModuleHoldCreateBuilder get _$this {
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
  void replace(ShipModuleHoldCreate other) {
    _$v = other as _$ShipModuleHoldCreate;
  }

  @override
  void update(void Function(ShipModuleHoldCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipModuleHoldCreate build() => _build();

  _$ShipModuleHoldCreate _build() {
    final _$result =
        _$v ??
        _$ShipModuleHoldCreate._(
          slot: BuiltValueNullFieldError.checkNotNull(
            slot,
            r'ShipModuleHoldCreate',
            'slot',
          ),
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'ShipModuleHoldCreate',
            'name',
          ),
          energyUse: BuiltValueNullFieldError.checkNotNull(
            energyUse,
            r'ShipModuleHoldCreate',
            'energyUse',
          ),
          cargoTons: cargoTons,
          concealed: concealed,
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
