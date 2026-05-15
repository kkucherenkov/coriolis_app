// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemTypeEnum _$itemTypeEnum_WEAPON = const ItemTypeEnum._('WEAPON');
const ItemTypeEnum _$itemTypeEnum_ARMOR = const ItemTypeEnum._('ARMOR');
const ItemTypeEnum _$itemTypeEnum_GEAR = const ItemTypeEnum._('GEAR');
const ItemTypeEnum _$itemTypeEnum_CYBERNETIC =
    const ItemTypeEnum._('CYBERNETIC');
const ItemTypeEnum _$itemTypeEnum_SHIP_MODULE =
    const ItemTypeEnum._('SHIP_MODULE');
const ItemTypeEnum _$itemTypeEnum_OTHER = const ItemTypeEnum._('OTHER');

ItemTypeEnum _$itemTypeEnumValueOf(String name) {
  switch (name) {
    case 'WEAPON':
      return _$itemTypeEnum_WEAPON;
    case 'ARMOR':
      return _$itemTypeEnum_ARMOR;
    case 'GEAR':
      return _$itemTypeEnum_GEAR;
    case 'CYBERNETIC':
      return _$itemTypeEnum_CYBERNETIC;
    case 'SHIP_MODULE':
      return _$itemTypeEnum_SHIP_MODULE;
    case 'OTHER':
      return _$itemTypeEnum_OTHER;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ItemTypeEnum> _$itemTypeEnumValues =
    BuiltSet<ItemTypeEnum>(const <ItemTypeEnum>[
  _$itemTypeEnum_WEAPON,
  _$itemTypeEnum_ARMOR,
  _$itemTypeEnum_GEAR,
  _$itemTypeEnum_CYBERNETIC,
  _$itemTypeEnum_SHIP_MODULE,
  _$itemTypeEnum_OTHER,
]);

Serializer<ItemTypeEnum> _$itemTypeEnumSerializer = _$ItemTypeEnumSerializer();

class _$ItemTypeEnumSerializer implements PrimitiveSerializer<ItemTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'WEAPON': 'WEAPON',
    'ARMOR': 'ARMOR',
    'GEAR': 'GEAR',
    'CYBERNETIC': 'CYBERNETIC',
    'SHIP_MODULE': 'SHIP_MODULE',
    'OTHER': 'OTHER',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'WEAPON': 'WEAPON',
    'ARMOR': 'ARMOR',
    'GEAR': 'GEAR',
    'CYBERNETIC': 'CYBERNETIC',
    'SHIP_MODULE': 'SHIP_MODULE',
    'OTHER': 'OTHER',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemTypeEnum];
  @override
  final String wireName = 'ItemTypeEnum';

  @override
  Object serialize(Serializers serializers, ItemTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Item extends Item {
  @override
  final OneOf oneOf;

  factory _$Item([void Function(ItemBuilder)? updates]) =>
      (ItemBuilder()..update(updates))._build();

  _$Item._({required this.oneOf}) : super._();
  @override
  Item rebuild(void Function(ItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemBuilder toBuilder() => ItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Item && oneOf == other.oneOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, oneOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Item')..add('oneOf', oneOf))
        .toString();
  }
}

class ItemBuilder implements Builder<Item, ItemBuilder> {
  _$Item? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  ItemBuilder() {
    Item._defaults(this);
  }

  ItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Item other) {
    _$v = other as _$Item;
  }

  @override
  void update(void Function(ItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Item build() => _build();

  _$Item _build() {
    final _$result = _$v ??
        _$Item._(
          oneOf: BuiltValueNullFieldError.checkNotNull(oneOf, r'Item', 'oneOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
