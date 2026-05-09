// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_gear_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemGearUpdateTypeEnum _$itemGearUpdateTypeEnum_GEAR =
    const ItemGearUpdateTypeEnum._('GEAR');

ItemGearUpdateTypeEnum _$itemGearUpdateTypeEnumValueOf(String name) {
  switch (name) {
    case 'GEAR':
      return _$itemGearUpdateTypeEnum_GEAR;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<ItemGearUpdateTypeEnum> _$itemGearUpdateTypeEnumValues =
    new BuiltSet<ItemGearUpdateTypeEnum>(const <ItemGearUpdateTypeEnum>[
  _$itemGearUpdateTypeEnum_GEAR,
]);

Serializer<ItemGearUpdateTypeEnum> _$itemGearUpdateTypeEnumSerializer =
    new _$ItemGearUpdateTypeEnumSerializer();

class _$ItemGearUpdateTypeEnumSerializer
    implements PrimitiveSerializer<ItemGearUpdateTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'GEAR': 'GEAR',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'GEAR': 'GEAR',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemGearUpdateTypeEnum];
  @override
  final String wireName = 'ItemGearUpdateTypeEnum';

  @override
  Object serialize(Serializers serializers, ItemGearUpdateTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemGearUpdateTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemGearUpdateTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ItemGearUpdate extends ItemGearUpdate {
  @override
  final ItemGearUpdateTypeEnum? type;
  @override
  final String? name;
  @override
  final num? weight;
  @override
  final int? quantity;
  @override
  final String? notes;

  factory _$ItemGearUpdate([void Function(ItemGearUpdateBuilder)? updates]) =>
      (new ItemGearUpdateBuilder()..update(updates))._build();

  _$ItemGearUpdate._(
      {this.type, this.name, this.weight, this.quantity, this.notes})
      : super._();

  @override
  ItemGearUpdate rebuild(void Function(ItemGearUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemGearUpdateBuilder toBuilder() =>
      new ItemGearUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemGearUpdate &&
        type == other.type &&
        name == other.name &&
        weight == other.weight &&
        quantity == other.quantity &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, weight.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ItemGearUpdate')
          ..add('type', type)
          ..add('name', name)
          ..add('weight', weight)
          ..add('quantity', quantity)
          ..add('notes', notes))
        .toString();
  }
}

class ItemGearUpdateBuilder
    implements Builder<ItemGearUpdate, ItemGearUpdateBuilder> {
  _$ItemGearUpdate? _$v;

  ItemGearUpdateTypeEnum? _type;
  ItemGearUpdateTypeEnum? get type => _$this._type;
  set type(ItemGearUpdateTypeEnum? type) => _$this._type = type;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  num? _weight;
  num? get weight => _$this._weight;
  set weight(num? weight) => _$this._weight = weight;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  ItemGearUpdateBuilder() {
    ItemGearUpdate._defaults(this);
  }

  ItemGearUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _name = $v.name;
      _weight = $v.weight;
      _quantity = $v.quantity;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ItemGearUpdate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ItemGearUpdate;
  }

  @override
  void update(void Function(ItemGearUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemGearUpdate build() => _build();

  _$ItemGearUpdate _build() {
    final _$result = _$v ??
        new _$ItemGearUpdate._(
            type: type,
            name: name,
            weight: weight,
            quantity: quantity,
            notes: notes);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
