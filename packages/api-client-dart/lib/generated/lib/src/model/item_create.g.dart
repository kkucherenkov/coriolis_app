// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemCreateTypeEnum _$itemCreateTypeEnum_WEAPON =
    const ItemCreateTypeEnum._('WEAPON');
const ItemCreateTypeEnum _$itemCreateTypeEnum_ARMOR =
    const ItemCreateTypeEnum._('ARMOR');
const ItemCreateTypeEnum _$itemCreateTypeEnum_GEAR =
    const ItemCreateTypeEnum._('GEAR');
const ItemCreateTypeEnum _$itemCreateTypeEnum_CYBERNETIC =
    const ItemCreateTypeEnum._('CYBERNETIC');
const ItemCreateTypeEnum _$itemCreateTypeEnum_SHIP_MODULE =
    const ItemCreateTypeEnum._('SHIP_MODULE');
const ItemCreateTypeEnum _$itemCreateTypeEnum_OTHER =
    const ItemCreateTypeEnum._('OTHER');

ItemCreateTypeEnum _$itemCreateTypeEnumValueOf(String name) {
  switch (name) {
    case 'WEAPON':
      return _$itemCreateTypeEnum_WEAPON;
    case 'ARMOR':
      return _$itemCreateTypeEnum_ARMOR;
    case 'GEAR':
      return _$itemCreateTypeEnum_GEAR;
    case 'CYBERNETIC':
      return _$itemCreateTypeEnum_CYBERNETIC;
    case 'SHIP_MODULE':
      return _$itemCreateTypeEnum_SHIP_MODULE;
    case 'OTHER':
      return _$itemCreateTypeEnum_OTHER;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ItemCreateTypeEnum> _$itemCreateTypeEnumValues =
    BuiltSet<ItemCreateTypeEnum>(const <ItemCreateTypeEnum>[
  _$itemCreateTypeEnum_WEAPON,
  _$itemCreateTypeEnum_ARMOR,
  _$itemCreateTypeEnum_GEAR,
  _$itemCreateTypeEnum_CYBERNETIC,
  _$itemCreateTypeEnum_SHIP_MODULE,
  _$itemCreateTypeEnum_OTHER,
]);

Serializer<ItemCreateTypeEnum> _$itemCreateTypeEnumSerializer =
    _$ItemCreateTypeEnumSerializer();

class _$ItemCreateTypeEnumSerializer
    implements PrimitiveSerializer<ItemCreateTypeEnum> {
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
  final Iterable<Type> types = const <Type>[ItemCreateTypeEnum];
  @override
  final String wireName = 'ItemCreateTypeEnum';

  @override
  Object serialize(Serializers serializers, ItemCreateTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemCreateTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemCreateTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ItemCreate extends ItemCreate {
  @override
  final OneOf oneOf;

  factory _$ItemCreate([void Function(ItemCreateBuilder)? updates]) =>
      (ItemCreateBuilder()..update(updates))._build();

  _$ItemCreate._({required this.oneOf}) : super._();
  @override
  ItemCreate rebuild(void Function(ItemCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemCreateBuilder toBuilder() => ItemCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemCreate && oneOf == other.oneOf;
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
    return (newBuiltValueToStringHelper(r'ItemCreate')..add('oneOf', oneOf))
        .toString();
  }
}

class ItemCreateBuilder implements Builder<ItemCreate, ItemCreateBuilder> {
  _$ItemCreate? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  ItemCreateBuilder() {
    ItemCreate._defaults(this);
  }

  ItemCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ItemCreate other) {
    _$v = other as _$ItemCreate;
  }

  @override
  void update(void Function(ItemCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemCreate build() => _build();

  _$ItemCreate _build() {
    final _$result = _$v ??
        _$ItemCreate._(
          oneOf: BuiltValueNullFieldError.checkNotNull(
              oneOf, r'ItemCreate', 'oneOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
