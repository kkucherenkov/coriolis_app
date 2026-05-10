// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_module_sensor_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ShipModuleSensorCreateSlotEnum _$shipModuleSensorCreateSlotEnum_SENSOR =
    const ShipModuleSensorCreateSlotEnum._('SENSOR');

ShipModuleSensorCreateSlotEnum _$shipModuleSensorCreateSlotEnumValueOf(
  String name,
) {
  switch (name) {
    case 'SENSOR':
      return _$shipModuleSensorCreateSlotEnum_SENSOR;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ShipModuleSensorCreateSlotEnum>
_$shipModuleSensorCreateSlotEnumValues =
    BuiltSet<ShipModuleSensorCreateSlotEnum>(
      const <ShipModuleSensorCreateSlotEnum>[
        _$shipModuleSensorCreateSlotEnum_SENSOR,
      ],
    );

Serializer<ShipModuleSensorCreateSlotEnum>
_$shipModuleSensorCreateSlotEnumSerializer =
    _$ShipModuleSensorCreateSlotEnumSerializer();

class _$ShipModuleSensorCreateSlotEnumSerializer
    implements PrimitiveSerializer<ShipModuleSensorCreateSlotEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'SENSOR': 'SENSOR',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'SENSOR': 'SENSOR',
  };

  @override
  final Iterable<Type> types = const <Type>[ShipModuleSensorCreateSlotEnum];
  @override
  final String wireName = 'ShipModuleSensorCreateSlotEnum';

  @override
  Object serialize(
    Serializers serializers,
    ShipModuleSensorCreateSlotEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ShipModuleSensorCreateSlotEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ShipModuleSensorCreateSlotEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ShipModuleSensorCreate extends ShipModuleSensorCreate {
  @override
  final ShipModuleSensorCreateSlotEnum slot;
  @override
  final String name;
  @override
  final int energyUse;
  @override
  final int? detectionBonus;
  @override
  final String? notes;

  factory _$ShipModuleSensorCreate([
    void Function(ShipModuleSensorCreateBuilder)? updates,
  ]) => (ShipModuleSensorCreateBuilder()..update(updates))._build();

  _$ShipModuleSensorCreate._({
    required this.slot,
    required this.name,
    required this.energyUse,
    this.detectionBonus,
    this.notes,
  }) : super._();
  @override
  ShipModuleSensorCreate rebuild(
    void Function(ShipModuleSensorCreateBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ShipModuleSensorCreateBuilder toBuilder() =>
      ShipModuleSensorCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipModuleSensorCreate &&
        slot == other.slot &&
        name == other.name &&
        energyUse == other.energyUse &&
        detectionBonus == other.detectionBonus &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, slot.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, energyUse.hashCode);
    _$hash = $jc(_$hash, detectionBonus.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShipModuleSensorCreate')
          ..add('slot', slot)
          ..add('name', name)
          ..add('energyUse', energyUse)
          ..add('detectionBonus', detectionBonus)
          ..add('notes', notes))
        .toString();
  }
}

class ShipModuleSensorCreateBuilder
    implements Builder<ShipModuleSensorCreate, ShipModuleSensorCreateBuilder> {
  _$ShipModuleSensorCreate? _$v;

  ShipModuleSensorCreateSlotEnum? _slot;
  ShipModuleSensorCreateSlotEnum? get slot => _$this._slot;
  set slot(ShipModuleSensorCreateSlotEnum? slot) => _$this._slot = slot;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _energyUse;
  int? get energyUse => _$this._energyUse;
  set energyUse(int? energyUse) => _$this._energyUse = energyUse;

  int? _detectionBonus;
  int? get detectionBonus => _$this._detectionBonus;
  set detectionBonus(int? detectionBonus) =>
      _$this._detectionBonus = detectionBonus;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  ShipModuleSensorCreateBuilder() {
    ShipModuleSensorCreate._defaults(this);
  }

  ShipModuleSensorCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _slot = $v.slot;
      _name = $v.name;
      _energyUse = $v.energyUse;
      _detectionBonus = $v.detectionBonus;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShipModuleSensorCreate other) {
    _$v = other as _$ShipModuleSensorCreate;
  }

  @override
  void update(void Function(ShipModuleSensorCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipModuleSensorCreate build() => _build();

  _$ShipModuleSensorCreate _build() {
    final _$result =
        _$v ??
        _$ShipModuleSensorCreate._(
          slot: BuiltValueNullFieldError.checkNotNull(
            slot,
            r'ShipModuleSensorCreate',
            'slot',
          ),
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'ShipModuleSensorCreate',
            'name',
          ),
          energyUse: BuiltValueNullFieldError.checkNotNull(
            energyUse,
            r'ShipModuleSensorCreate',
            'energyUse',
          ),
          detectionBonus: detectionBonus,
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
