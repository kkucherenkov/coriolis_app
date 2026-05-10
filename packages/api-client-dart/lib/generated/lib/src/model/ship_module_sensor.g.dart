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
  Object serialize(
    Serializers serializers,
    ShipModuleSensorSlotEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ShipModuleSensorSlotEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ShipModuleSensorSlotEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ShipModuleSensor extends ShipModuleSensor {
  @override
  final int? detectionBonus;

  factory _$ShipModuleSensor([
    void Function(ShipModuleSensorBuilder)? updates,
  ]) => (ShipModuleSensorBuilder()..update(updates))._build();

  _$ShipModuleSensor._({this.detectionBonus}) : super._();
  @override
  ShipModuleSensor rebuild(void Function(ShipModuleSensorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipModuleSensorBuilder toBuilder() =>
      ShipModuleSensorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipModuleSensor && detectionBonus == other.detectionBonus;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, detectionBonus.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'ShipModuleSensor',
    )..add('detectionBonus', detectionBonus)).toString();
  }
}

class ShipModuleSensorBuilder
    implements Builder<ShipModuleSensor, ShipModuleSensorBuilder> {
  _$ShipModuleSensor? _$v;

  int? _detectionBonus;
  int? get detectionBonus => _$this._detectionBonus;
  set detectionBonus(int? detectionBonus) =>
      _$this._detectionBonus = detectionBonus;

  ShipModuleSensorBuilder() {
    ShipModuleSensor._defaults(this);
  }

  ShipModuleSensorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _detectionBonus = $v.detectionBonus;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShipModuleSensor other) {
    _$v = other as _$ShipModuleSensor;
  }

  @override
  void update(void Function(ShipModuleSensorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipModuleSensor build() => _build();

  _$ShipModuleSensor _build() {
    final _$result =
        _$v ?? _$ShipModuleSensor._(detectionBonus: detectionBonus);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
