// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_cybernetic.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemCyberneticTypeEnum _$itemCyberneticTypeEnum_CYBERNETIC =
    const ItemCyberneticTypeEnum._('CYBERNETIC');

ItemCyberneticTypeEnum _$itemCyberneticTypeEnumValueOf(String name) {
  switch (name) {
    case 'CYBERNETIC':
      return _$itemCyberneticTypeEnum_CYBERNETIC;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ItemCyberneticTypeEnum> _$itemCyberneticTypeEnumValues =
    BuiltSet<ItemCyberneticTypeEnum>(const <ItemCyberneticTypeEnum>[
  _$itemCyberneticTypeEnum_CYBERNETIC,
]);

Serializer<ItemCyberneticTypeEnum> _$itemCyberneticTypeEnumSerializer =
    _$ItemCyberneticTypeEnumSerializer();

class _$ItemCyberneticTypeEnumSerializer
    implements PrimitiveSerializer<ItemCyberneticTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'CYBERNETIC': 'CYBERNETIC',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'CYBERNETIC': 'CYBERNETIC',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemCyberneticTypeEnum];
  @override
  final String wireName = 'ItemCyberneticTypeEnum';

  @override
  Object serialize(Serializers serializers, ItemCyberneticTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemCyberneticTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemCyberneticTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ItemCybernetic extends ItemCybernetic {
  @override
  final String effect;
  @override
  final int xpCost;
  @override
  final String id;
  @override
  final String type;
  @override
  final String name;

  factory _$ItemCybernetic([void Function(ItemCyberneticBuilder)? updates]) =>
      (ItemCyberneticBuilder()..update(updates))._build();

  _$ItemCybernetic._(
      {required this.effect,
      required this.xpCost,
      required this.id,
      required this.type,
      required this.name})
      : super._();
  @override
  ItemCybernetic rebuild(void Function(ItemCyberneticBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemCyberneticBuilder toBuilder() => ItemCyberneticBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemCybernetic &&
        effect == other.effect &&
        xpCost == other.xpCost &&
        id == other.id &&
        type == other.type &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, effect.hashCode);
    _$hash = $jc(_$hash, xpCost.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ItemCybernetic')
          ..add('effect', effect)
          ..add('xpCost', xpCost)
          ..add('id', id)
          ..add('type', type)
          ..add('name', name))
        .toString();
  }
}

class ItemCyberneticBuilder
    implements Builder<ItemCybernetic, ItemCyberneticBuilder>, ItemBaseBuilder {
  _$ItemCybernetic? _$v;

  String? _effect;
  String? get effect => _$this._effect;
  set effect(covariant String? effect) => _$this._effect = effect;

  int? _xpCost;
  int? get xpCost => _$this._xpCost;
  set xpCost(covariant int? xpCost) => _$this._xpCost = xpCost;

  String? _id;
  String? get id => _$this._id;
  set id(covariant String? id) => _$this._id = id;

  String? _type;
  String? get type => _$this._type;
  set type(covariant String? type) => _$this._type = type;

  String? _name;
  String? get name => _$this._name;
  set name(covariant String? name) => _$this._name = name;

  ItemCyberneticBuilder() {
    ItemCybernetic._defaults(this);
  }

  ItemCyberneticBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _effect = $v.effect;
      _xpCost = $v.xpCost;
      _id = $v.id;
      _type = $v.type;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant ItemCybernetic other) {
    _$v = other as _$ItemCybernetic;
  }

  @override
  void update(void Function(ItemCyberneticBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemCybernetic build() => _build();

  _$ItemCybernetic _build() {
    final _$result = _$v ??
        _$ItemCybernetic._(
          effect: BuiltValueNullFieldError.checkNotNull(
              effect, r'ItemCybernetic', 'effect'),
          xpCost: BuiltValueNullFieldError.checkNotNull(
              xpCost, r'ItemCybernetic', 'xpCost'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ItemCybernetic', 'id'),
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'ItemCybernetic', 'type'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'ItemCybernetic', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
