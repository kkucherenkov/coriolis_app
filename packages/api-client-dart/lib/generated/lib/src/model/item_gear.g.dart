// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_gear.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemGearTypeEnum _$itemGearTypeEnum_GEAR = const ItemGearTypeEnum._(
  'GEAR',
);

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
  Object serialize(
    Serializers serializers,
    ItemGearTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ItemGearTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ItemGearTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ItemGear extends ItemGear {
  @override
  final int quantity;
  @override
  final String? notes;
  @override
  final num weight;

  factory _$ItemGear([void Function(ItemGearBuilder)? updates]) =>
      (ItemGearBuilder()..update(updates))._build();

  _$ItemGear._({required this.quantity, this.notes, required this.weight})
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
        weight == other.weight;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, weight.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ItemGear')
          ..add('quantity', quantity)
          ..add('notes', notes)
          ..add('weight', weight))
        .toString();
  }
}

class ItemGearBuilder implements Builder<ItemGear, ItemGearBuilder> {
  _$ItemGear? _$v;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  num? _weight;
  num? get weight => _$this._weight;
  set weight(num? weight) => _$this._weight = weight;

  ItemGearBuilder() {
    ItemGear._defaults(this);
  }

  ItemGearBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _quantity = $v.quantity;
      _notes = $v.notes;
      _weight = $v.weight;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ItemGear other) {
    _$v = other as _$ItemGear;
  }

  @override
  void update(void Function(ItemGearBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemGear build() => _build();

  _$ItemGear _build() {
    final _$result =
        _$v ??
        _$ItemGear._(
          quantity: BuiltValueNullFieldError.checkNotNull(
            quantity,
            r'ItemGear',
            'quantity',
          ),
          notes: notes,
          weight: BuiltValueNullFieldError.checkNotNull(
            weight,
            r'ItemGear',
            'weight',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
