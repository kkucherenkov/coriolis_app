// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_weapon_range.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ShipWeaponRange _$zero = const ShipWeaponRange._('zero');
const ShipWeaponRange _$close = const ShipWeaponRange._('close');
const ShipWeaponRange _$medium = const ShipWeaponRange._('medium');
const ShipWeaponRange _$long = const ShipWeaponRange._('long');
const ShipWeaponRange _$extreme = const ShipWeaponRange._('extreme');

ShipWeaponRange _$valueOf(String name) {
  switch (name) {
    case 'zero':
      return _$zero;
    case 'close':
      return _$close;
    case 'medium':
      return _$medium;
    case 'long':
      return _$long;
    case 'extreme':
      return _$extreme;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<ShipWeaponRange> _$values =
    new BuiltSet<ShipWeaponRange>(const <ShipWeaponRange>[
  _$zero,
  _$close,
  _$medium,
  _$long,
  _$extreme,
]);

class _$ShipWeaponRangeMeta {
  const _$ShipWeaponRangeMeta();
  ShipWeaponRange get zero => _$zero;
  ShipWeaponRange get close => _$close;
  ShipWeaponRange get medium => _$medium;
  ShipWeaponRange get long => _$long;
  ShipWeaponRange get extreme => _$extreme;
  ShipWeaponRange valueOf(String name) => _$valueOf(name);
  BuiltSet<ShipWeaponRange> get values => _$values;
}

abstract class _$ShipWeaponRangeMixin {
  // ignore: non_constant_identifier_names
  _$ShipWeaponRangeMeta get ShipWeaponRange => const _$ShipWeaponRangeMeta();
}

Serializer<ShipWeaponRange> _$shipWeaponRangeSerializer =
    new _$ShipWeaponRangeSerializer();

class _$ShipWeaponRangeSerializer
    implements PrimitiveSerializer<ShipWeaponRange> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'zero': 'zero',
    'close': 'close',
    'medium': 'medium',
    'long': 'long',
    'extreme': 'extreme',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'zero': 'zero',
    'close': 'close',
    'medium': 'medium',
    'long': 'long',
    'extreme': 'extreme',
  };

  @override
  final Iterable<Type> types = const <Type>[ShipWeaponRange];
  @override
  final String wireName = 'ShipWeaponRange';

  @override
  Object serialize(Serializers serializers, ShipWeaponRange object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ShipWeaponRange deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ShipWeaponRange.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
