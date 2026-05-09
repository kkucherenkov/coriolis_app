// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_module_sensor_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ShipModuleSensorUpdateSlotEnum _$shipModuleSensorUpdateSlotEnum_SENSOR =
    const ShipModuleSensorUpdateSlotEnum._('SENSOR');

ShipModuleSensorUpdateSlotEnum _$shipModuleSensorUpdateSlotEnumValueOf(
    String name) {
  switch (name) {
    case 'SENSOR':
      return _$shipModuleSensorUpdateSlotEnum_SENSOR;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<ShipModuleSensorUpdateSlotEnum>
    _$shipModuleSensorUpdateSlotEnumValues = new BuiltSet<
        ShipModuleSensorUpdateSlotEnum>(const <ShipModuleSensorUpdateSlotEnum>[
  _$shipModuleSensorUpdateSlotEnum_SENSOR,
]);

Serializer<ShipModuleSensorUpdateSlotEnum>
    _$shipModuleSensorUpdateSlotEnumSerializer =
    new _$ShipModuleSensorUpdateSlotEnumSerializer();

class _$ShipModuleSensorUpdateSlotEnumSerializer
    implements PrimitiveSerializer<ShipModuleSensorUpdateSlotEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'SENSOR': 'SENSOR',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'SENSOR': 'SENSOR',
  };

  @override
  final Iterable<Type> types = const <Type>[ShipModuleSensorUpdateSlotEnum];
  @override
  final String wireName = 'ShipModuleSensorUpdateSlotEnum';

  @override
  Object serialize(
          Serializers serializers, ShipModuleSensorUpdateSlotEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ShipModuleSensorUpdateSlotEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ShipModuleSensorUpdateSlotEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ShipModuleSensorUpdate extends ShipModuleSensorUpdate {
  @override
  final ShipModuleSensorUpdateSlotEnum? slot;
  @override
  final String? name;
  @override
  final int? energyUse;
  @override
  final int? detectionBonus;
  @override
  final String? notes;

  factory _$ShipModuleSensorUpdate(
          [void Function(ShipModuleSensorUpdateBuilder)? updates]) =>
      (new ShipModuleSensorUpdateBuilder()..update(updates))._build();

  _$ShipModuleSensorUpdate._(
      {this.slot, this.name, this.energyUse, this.detectionBonus, this.notes})
      : super._();

  @override
  ShipModuleSensorUpdate rebuild(
          void Function(ShipModuleSensorUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipModuleSensorUpdateBuilder toBuilder() =>
      new ShipModuleSensorUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipModuleSensorUpdate &&
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
    return (newBuiltValueToStringHelper(r'ShipModuleSensorUpdate')
          ..add('slot', slot)
          ..add('name', name)
          ..add('energyUse', energyUse)
          ..add('detectionBonus', detectionBonus)
          ..add('notes', notes))
        .toString();
  }
}

class ShipModuleSensorUpdateBuilder
    implements Builder<ShipModuleSensorUpdate, ShipModuleSensorUpdateBuilder> {
  _$ShipModuleSensorUpdate? _$v;

  ShipModuleSensorUpdateSlotEnum? _slot;
  ShipModuleSensorUpdateSlotEnum? get slot => _$this._slot;
  set slot(ShipModuleSensorUpdateSlotEnum? slot) => _$this._slot = slot;

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

  ShipModuleSensorUpdateBuilder() {
    ShipModuleSensorUpdate._defaults(this);
  }

  ShipModuleSensorUpdateBuilder get _$this {
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
  void replace(ShipModuleSensorUpdate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ShipModuleSensorUpdate;
  }

  @override
  void update(void Function(ShipModuleSensorUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipModuleSensorUpdate build() => _build();

  _$ShipModuleSensorUpdate _build() {
    final _$result = _$v ??
        new _$ShipModuleSensorUpdate._(
            slot: slot,
            name: name,
            energyUse: energyUse,
            detectionBonus: detectionBonus,
            notes: notes);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
