// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_range_enum.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemRangeEnum _$arm = const ItemRangeEnum._('arm');
const ItemRangeEnum _$near = const ItemRangeEnum._('near');
const ItemRangeEnum _$short = const ItemRangeEnum._('short');
const ItemRangeEnum _$long = const ItemRangeEnum._('long');
const ItemRangeEnum _$distant = const ItemRangeEnum._('distant');

ItemRangeEnum _$valueOf(String name) {
  switch (name) {
    case 'arm':
      return _$arm;
    case 'near':
      return _$near;
    case 'short':
      return _$short;
    case 'long':
      return _$long;
    case 'distant':
      return _$distant;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<ItemRangeEnum> _$values =
    new BuiltSet<ItemRangeEnum>(const <ItemRangeEnum>[
  _$arm,
  _$near,
  _$short,
  _$long,
  _$distant,
]);

class _$ItemRangeEnumMeta {
  const _$ItemRangeEnumMeta();
  ItemRangeEnum get arm => _$arm;
  ItemRangeEnum get near => _$near;
  ItemRangeEnum get short => _$short;
  ItemRangeEnum get long => _$long;
  ItemRangeEnum get distant => _$distant;
  ItemRangeEnum valueOf(String name) => _$valueOf(name);
  BuiltSet<ItemRangeEnum> get values => _$values;
}

abstract class _$ItemRangeEnumMixin {
  // ignore: non_constant_identifier_names
  _$ItemRangeEnumMeta get ItemRangeEnum => const _$ItemRangeEnumMeta();
}

Serializer<ItemRangeEnum> _$itemRangeEnumSerializer =
    new _$ItemRangeEnumSerializer();

class _$ItemRangeEnumSerializer implements PrimitiveSerializer<ItemRangeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'arm': 'arm',
    'near': 'near',
    'short': 'short',
    'long': 'long',
    'distant': 'distant',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'arm': 'arm',
    'near': 'near',
    'short': 'short',
    'long': 'long',
    'distant': 'distant',
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
