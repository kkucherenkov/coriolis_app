// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_slot_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemSlotType _$bridge = const ItemSlotType._('bridge');
const ItemSlotType _$hull = const ItemSlotType._('hull');
const ItemSlotType _$hold = const ItemSlotType._('hold');
const ItemSlotType _$weapon = const ItemSlotType._('weapon');
const ItemSlotType _$drive = const ItemSlotType._('drive');
const ItemSlotType _$sensor = const ItemSlotType._('sensor');
const ItemSlotType _$comms = const ItemSlotType._('comms');

ItemSlotType _$valueOf(String name) {
  switch (name) {
    case 'bridge':
      return _$bridge;
    case 'hull':
      return _$hull;
    case 'hold':
      return _$hold;
    case 'weapon':
      return _$weapon;
    case 'drive':
      return _$drive;
    case 'sensor':
      return _$sensor;
    case 'comms':
      return _$comms;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<ItemSlotType> _$values =
    new BuiltSet<ItemSlotType>(const <ItemSlotType>[
  _$bridge,
  _$hull,
  _$hold,
  _$weapon,
  _$drive,
  _$sensor,
  _$comms,
]);

class _$ItemSlotTypeMeta {
  const _$ItemSlotTypeMeta();
  ItemSlotType get bridge => _$bridge;
  ItemSlotType get hull => _$hull;
  ItemSlotType get hold => _$hold;
  ItemSlotType get weapon => _$weapon;
  ItemSlotType get drive => _$drive;
  ItemSlotType get sensor => _$sensor;
  ItemSlotType get comms => _$comms;
  ItemSlotType valueOf(String name) => _$valueOf(name);
  BuiltSet<ItemSlotType> get values => _$values;
}

abstract class _$ItemSlotTypeMixin {
  // ignore: non_constant_identifier_names
  _$ItemSlotTypeMeta get ItemSlotType => const _$ItemSlotTypeMeta();
}

Serializer<ItemSlotType> _$itemSlotTypeSerializer =
    new _$ItemSlotTypeSerializer();

class _$ItemSlotTypeSerializer implements PrimitiveSerializer<ItemSlotType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'bridge': 'bridge',
    'hull': 'hull',
    'hold': 'hold',
    'weapon': 'weapon',
    'drive': 'drive',
    'sensor': 'sensor',
    'comms': 'comms',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'bridge': 'bridge',
    'hull': 'hull',
    'hold': 'hold',
    'weapon': 'weapon',
    'drive': 'drive',
    'sensor': 'sensor',
    'comms': 'comms',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemSlotType];
  @override
  final String wireName = 'ItemSlotType';

  @override
  Object serialize(Serializers serializers, ItemSlotType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemSlotType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemSlotType.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
