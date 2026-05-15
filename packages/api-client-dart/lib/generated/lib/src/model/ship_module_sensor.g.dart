// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_module_sensor.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ShipModuleSensorSlotEnum _$shipModuleSensorSlotEnum_SENSOR =
    const ShipModuleSensorSlotEnum._('SENSOR');

ShipModuleSensorSlotEnum _$shipModuleSensorSlotEnumValueOf(String name) {
  switch (name) {
    case 'SENSOR':
      return _$shipModuleSensorSlotEnum_SENSOR;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ShipModuleSensorSlotEnum> _$shipModuleSensorSlotEnumValues =
    BuiltSet<ShipModuleSensorSlotEnum>(const <ShipModuleSensorSlotEnum>[
  _$shipModuleSensorSlotEnum_SENSOR,
]);

Serializer<ShipModuleSensorSlotEnum> _$shipModuleSensorSlotEnumSerializer =
    _$ShipModuleSensorSlotEnumSerializer();

class _$ShipModuleSensorSlotEnumSerializer
    implements PrimitiveSerializer<ShipModuleSensorSlotEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'SENSOR': 'SENSOR',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'SENSOR': 'SENSOR',
  };

  @override
  final Iterable<Type> types = const <Type>[ShipModuleSensorSlotEnum];
  @override
  final String wireName = 'ShipModuleSensorSlotEnum';

  @override
  Object serialize(Serializers serializers, ShipModuleSensorSlotEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ShipModuleSensorSlotEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ShipModuleSensorSlotEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ShipModuleSensor extends ShipModuleSensor {
  @override
  final int? detectionBonus;
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

  factory _$ShipModuleSensor(
          [void Function(ShipModuleSensorBuilder)? updates]) =>
      (ShipModuleSensorBuilder()..update(updates))._build();

  _$ShipModuleSensor._(
      {this.detectionBonus,
      required this.id,
      required this.slot,
      required this.name,
      required this.energyUse,
      this.notes})
      : super._();
  @override
  ShipModuleSensor rebuild(void Function(ShipModuleSensorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipModuleSensorBuilder toBuilder() =>
      ShipModuleSensorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipModuleSensor &&
        detectionBonus == other.detectionBonus &&
        id == other.id &&
        slot == other.slot &&
        name == other.name &&
        energyUse == other.energyUse &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, detectionBonus.hashCode);
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
    return (newBuiltValueToStringHelper(r'ShipModuleSensor')
          ..add('detectionBonus', detectionBonus)
          ..add('id', id)
          ..add('slot', slot)
          ..add('name', name)
          ..add('energyUse', energyUse)
          ..add('notes', notes))
        .toString();
  }
}

class ShipModuleSensorBuilder
    implements
        Builder<ShipModuleSensor, ShipModuleSensorBuilder>,
        ShipModuleBaseBuilder {
  _$ShipModuleSensor? _$v;

  int? _detectionBonus;
  int? get detectionBonus => _$this._detectionBonus;
  set detectionBonus(covariant int? detectionBonus) =>
      _$this._detectionBonus = detectionBonus;

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

  ShipModuleSensorBuilder() {
    ShipModuleSensor._defaults(this);
  }

  ShipModuleSensorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _detectionBonus = $v.detectionBonus;
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
  void replace(covariant ShipModuleSensor other) {
    _$v = other as _$ShipModuleSensor;
  }

  @override
  void update(void Function(ShipModuleSensorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipModuleSensor build() => _build();

  _$ShipModuleSensor _build() {
    final _$result = _$v ??
        _$ShipModuleSensor._(
          detectionBonus: detectionBonus,
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ShipModuleSensor', 'id'),
          slot: BuiltValueNullFieldError.checkNotNull(
              slot, r'ShipModuleSensor', 'slot'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'ShipModuleSensor', 'name'),
          energyUse: BuiltValueNullFieldError.checkNotNull(
              energyUse, r'ShipModuleSensor', 'energyUse'),
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
