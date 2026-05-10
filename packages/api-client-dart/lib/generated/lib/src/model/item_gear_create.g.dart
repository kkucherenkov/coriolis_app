// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_gear_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemGearCreateTypeEnum _$itemGearCreateTypeEnum_GEAR =
    const ItemGearCreateTypeEnum._('GEAR');

ItemGearCreateTypeEnum _$itemGearCreateTypeEnumValueOf(String name) {
  switch (name) {
    case 'GEAR':
      return _$itemGearCreateTypeEnum_GEAR;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ItemGearCreateTypeEnum> _$itemGearCreateTypeEnumValues =
    BuiltSet<ItemGearCreateTypeEnum>(const <ItemGearCreateTypeEnum>[
      _$itemGearCreateTypeEnum_GEAR,
    ]);

Serializer<ItemGearCreateTypeEnum> _$itemGearCreateTypeEnumSerializer =
    _$ItemGearCreateTypeEnumSerializer();

class _$ItemGearCreateTypeEnumSerializer
    implements PrimitiveSerializer<ItemGearCreateTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'GEAR': 'GEAR',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'GEAR': 'GEAR',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemGearCreateTypeEnum];
  @override
  final String wireName = 'ItemGearCreateTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ItemGearCreateTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ItemGearCreateTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ItemGearCreateTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ItemGearCreate extends ItemGearCreate {
  @override
  final ItemGearCreateTypeEnum type;
  @override
  final String name;
  @override
  final num weight;
  @override
  final int quantity;
  @override
  final String? notes;

  factory _$ItemGearCreate([void Function(ItemGearCreateBuilder)? updates]) =>
      (ItemGearCreateBuilder()..update(updates))._build();

  _$ItemGearCreate._({
    required this.type,
    required this.name,
    required this.weight,
    required this.quantity,
    this.notes,
  }) : super._();
  @override
  ItemGearCreate rebuild(void Function(ItemGearCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemGearCreateBuilder toBuilder() => ItemGearCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemGearCreate &&
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
    return (newBuiltValueToStringHelper(r'ItemGearCreate')
          ..add('type', type)
          ..add('name', name)
          ..add('weight', weight)
          ..add('quantity', quantity)
          ..add('notes', notes))
        .toString();
  }
}

class ItemGearCreateBuilder
    implements Builder<ItemGearCreate, ItemGearCreateBuilder> {
  _$ItemGearCreate? _$v;

  ItemGearCreateTypeEnum? _type;
  ItemGearCreateTypeEnum? get type => _$this._type;
  set type(ItemGearCreateTypeEnum? type) => _$this._type = type;

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

  ItemGearCreateBuilder() {
    ItemGearCreate._defaults(this);
  }

  ItemGearCreateBuilder get _$this {
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
  void replace(ItemGearCreate other) {
    _$v = other as _$ItemGearCreate;
  }

  @override
  void update(void Function(ItemGearCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemGearCreate build() => _build();

  _$ItemGearCreate _build() {
    final _$result =
        _$v ??
        _$ItemGearCreate._(
          type: BuiltValueNullFieldError.checkNotNull(
            type,
            r'ItemGearCreate',
            'type',
          ),
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'ItemGearCreate',
            'name',
          ),
          weight: BuiltValueNullFieldError.checkNotNull(
            weight,
            r'ItemGearCreate',
            'weight',
          ),
          quantity: BuiltValueNullFieldError.checkNotNull(
            quantity,
            r'ItemGearCreate',
            'quantity',
          ),
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
