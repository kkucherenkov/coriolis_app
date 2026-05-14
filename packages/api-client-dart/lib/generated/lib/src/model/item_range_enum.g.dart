// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_range_enum.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemRangeEnum _$close = const ItemRangeEnum._('close');
const ItemRangeEnum _$medium = const ItemRangeEnum._('medium');
const ItemRangeEnum _$long = const ItemRangeEnum._('long');
const ItemRangeEnum _$extreme = const ItemRangeEnum._('extreme');

ItemRangeEnum _$valueOf(String name) {
  switch (name) {
    case 'close':
      return _$close;
    case 'medium':
      return _$medium;
    case 'long':
      return _$long;
    case 'extreme':
      return _$extreme;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ItemRangeEnum> _$values =
    BuiltSet<ItemRangeEnum>(const <ItemRangeEnum>[
  _$close,
  _$medium,
  _$long,
  _$extreme,
]);

class _$ItemRangeEnumMeta {
  const _$ItemRangeEnumMeta();
  ItemRangeEnum get close => _$close;
  ItemRangeEnum get medium => _$medium;
  ItemRangeEnum get long => _$long;
  ItemRangeEnum get extreme => _$extreme;
  ItemRangeEnum valueOf(String name) => _$valueOf(name);
  BuiltSet<ItemRangeEnum> get values => _$values;
}

abstract class _$ItemRangeEnumMixin {
  // ignore: non_constant_identifier_names
  _$ItemRangeEnumMeta get ItemRangeEnum => const _$ItemRangeEnumMeta();
}

Serializer<ItemRangeEnum> _$itemRangeEnumSerializer =
    _$ItemRangeEnumSerializer();

class _$ItemRangeEnumSerializer implements PrimitiveSerializer<ItemRangeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'close': 'close',
    'medium': 'medium',
    'long': 'long',
    'extreme': 'extreme',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'close': 'close',
    'medium': 'medium',
    'long': 'long',
    'extreme': 'extreme',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemRangeEnum];
  @override
  final String wireName = 'ItemRangeEnum';

  @override
  Object serialize(Serializers serializers, ItemRangeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemRangeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemRangeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
