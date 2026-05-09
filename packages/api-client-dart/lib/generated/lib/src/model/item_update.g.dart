// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemUpdateTypeEnum _$itemUpdateTypeEnum_WEAPON =
    const ItemUpdateTypeEnum._('WEAPON');
const ItemUpdateTypeEnum _$itemUpdateTypeEnum_ARMOR =
    const ItemUpdateTypeEnum._('ARMOR');
const ItemUpdateTypeEnum _$itemUpdateTypeEnum_GEAR =
    const ItemUpdateTypeEnum._('GEAR');
const ItemUpdateTypeEnum _$itemUpdateTypeEnum_CYBERNETIC =
    const ItemUpdateTypeEnum._('CYBERNETIC');
const ItemUpdateTypeEnum _$itemUpdateTypeEnum_SHIP_MODULE =
    const ItemUpdateTypeEnum._('SHIP_MODULE');
const ItemUpdateTypeEnum _$itemUpdateTypeEnum_OTHER =
    const ItemUpdateTypeEnum._('OTHER');

ItemUpdateTypeEnum _$itemUpdateTypeEnumValueOf(String name) {
  switch (name) {
    case 'WEAPON':
      return _$itemUpdateTypeEnum_WEAPON;
    case 'ARMOR':
      return _$itemUpdateTypeEnum_ARMOR;
    case 'GEAR':
      return _$itemUpdateTypeEnum_GEAR;
    case 'CYBERNETIC':
      return _$itemUpdateTypeEnum_CYBERNETIC;
    case 'SHIP_MODULE':
      return _$itemUpdateTypeEnum_SHIP_MODULE;
    case 'OTHER':
      return _$itemUpdateTypeEnum_OTHER;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<ItemUpdateTypeEnum> _$itemUpdateTypeEnumValues =
    new BuiltSet<ItemUpdateTypeEnum>(const <ItemUpdateTypeEnum>[
  _$itemUpdateTypeEnum_WEAPON,
  _$itemUpdateTypeEnum_ARMOR,
  _$itemUpdateTypeEnum_GEAR,
  _$itemUpdateTypeEnum_CYBERNETIC,
  _$itemUpdateTypeEnum_SHIP_MODULE,
  _$itemUpdateTypeEnum_OTHER,
]);

Serializer<ItemUpdateTypeEnum> _$itemUpdateTypeEnumSerializer =
    new _$ItemUpdateTypeEnumSerializer();

class _$ItemUpdateTypeEnumSerializer
    implements PrimitiveSerializer<ItemUpdateTypeEnum> {
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
  final Iterable<Type> types = const <Type>[ItemUpdateTypeEnum];
  @override
  final String wireName = 'ItemUpdateTypeEnum';

  @override
  Object serialize(Serializers serializers, ItemUpdateTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemUpdateTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemUpdateTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ItemUpdate extends ItemUpdate {
  @override
  final OneOf oneOf;

  factory _$ItemUpdate([void Function(ItemUpdateBuilder)? updates]) =>
      (new ItemUpdateBuilder()..update(updates))._build();

  _$ItemUpdate._({required this.oneOf}) : super._() {
    BuiltValueNullFieldError.checkNotNull(oneOf, r'ItemUpdate', 'oneOf');
  }

  @override
  ItemUpdate rebuild(void Function(ItemUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemUpdateBuilder toBuilder() => new ItemUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemUpdate && oneOf == other.oneOf;
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
    return (newBuiltValueToStringHelper(r'ItemUpdate')..add('oneOf', oneOf))
        .toString();
  }
}

class ItemUpdateBuilder implements Builder<ItemUpdate, ItemUpdateBuilder> {
  _$ItemUpdate? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  ItemUpdateBuilder() {
    ItemUpdate._defaults(this);
  }

  ItemUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ItemUpdate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ItemUpdate;
  }

  @override
  void update(void Function(ItemUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemUpdate build() => _build();

  _$ItemUpdate _build() {
    final _$result = _$v ??
        new _$ItemUpdate._(
            oneOf: BuiltValueNullFieldError.checkNotNull(
                oneOf, r'ItemUpdate', 'oneOf'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
