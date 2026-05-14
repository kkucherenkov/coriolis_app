// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_gear.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemGearTypeEnum _$itemGearTypeEnum_GEAR =
    const ItemGearTypeEnum._('GEAR');

ItemGearTypeEnum _$itemGearTypeEnumValueOf(String name) {
  switch (name) {
    case 'GEAR':
      return _$itemGearTypeEnum_GEAR;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ItemGearTypeEnum> _$itemGearTypeEnumValues =
    BuiltSet<ItemGearTypeEnum>(const <ItemGearTypeEnum>[
  _$itemGearTypeEnum_GEAR,
]);

Serializer<ItemGearTypeEnum> _$itemGearTypeEnumSerializer =
    _$ItemGearTypeEnumSerializer();

class _$ItemGearTypeEnumSerializer
    implements PrimitiveSerializer<ItemGearTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'GEAR': 'GEAR',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'GEAR': 'GEAR',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemGearTypeEnum];
  @override
  final String wireName = 'ItemGearTypeEnum';

  @override
  Object serialize(Serializers serializers, ItemGearTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemGearTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemGearTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ItemGear extends ItemGear {
  @override
  final int quantity;
  @override
  final String? notes;
  @override
  final num weight;
  @override
  final String id;
  @override
  final String type;
  @override
  final String name;

  factory _$ItemGear([void Function(ItemGearBuilder)? updates]) =>
      (ItemGearBuilder()..update(updates))._build();

  _$ItemGear._(
      {required this.quantity,
      this.notes,
      required this.weight,
      required this.id,
      required this.type,
      required this.name})
      : super._();
  @override
  ItemGear rebuild(void Function(ItemGearBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemGearBuilder toBuilder() => ItemGearBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemGear &&
        quantity == other.quantity &&
        notes == other.notes &&
        weight == other.weight &&
        id == other.id &&
        type == other.type &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, weight.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ItemGear')
          ..add('quantity', quantity)
          ..add('notes', notes)
          ..add('weight', weight)
          ..add('id', id)
          ..add('type', type)
          ..add('name', name))
        .toString();
  }
}

class ItemGearBuilder
    implements Builder<ItemGear, ItemGearBuilder>, ItemBaseBuilder {
  _$ItemGear? _$v;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(covariant int? quantity) => _$this._quantity = quantity;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(covariant String? notes) => _$this._notes = notes;

  num? _weight;
  num? get weight => _$this._weight;
  set weight(covariant num? weight) => _$this._weight = weight;

  String? _id;
  String? get id => _$this._id;
  set id(covariant String? id) => _$this._id = id;

  String? _type;
  String? get type => _$this._type;
  set type(covariant String? type) => _$this._type = type;

  String? _name;
  String? get name => _$this._name;
  set name(covariant String? name) => _$this._name = name;

  ItemGearBuilder() {
    ItemGear._defaults(this);
  }

  ItemGearBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _quantity = $v.quantity;
      _notes = $v.notes;
      _weight = $v.weight;
      _id = $v.id;
      _type = $v.type;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant ItemGear other) {
    _$v = other as _$ItemGear;
  }

  @override
  void update(void Function(ItemGearBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemGear build() => _build();

  _$ItemGear _build() {
    final _$result = _$v ??
        _$ItemGear._(
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'ItemGear', 'quantity'),
          notes: notes,
          weight: BuiltValueNullFieldError.checkNotNull(
              weight, r'ItemGear', 'weight'),
          id: BuiltValueNullFieldError.checkNotNull(id, r'ItemGear', 'id'),
          type:
              BuiltValueNullFieldError.checkNotNull(type, r'ItemGear', 'type'),
          name:
              BuiltValueNullFieldError.checkNotNull(name, r'ItemGear', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
