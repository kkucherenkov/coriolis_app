// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_ship_module_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemShipModuleCreateTypeEnum _$itemShipModuleCreateTypeEnum_SHIP_MODULE =
    const ItemShipModuleCreateTypeEnum._('SHIP_MODULE');

ItemShipModuleCreateTypeEnum _$itemShipModuleCreateTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'SHIP_MODULE':
      return _$itemShipModuleCreateTypeEnum_SHIP_MODULE;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ItemShipModuleCreateTypeEnum>
    _$itemShipModuleCreateTypeEnumValues =
    BuiltSet<ItemShipModuleCreateTypeEnum>(const <ItemShipModuleCreateTypeEnum>[
  _$itemShipModuleCreateTypeEnum_SHIP_MODULE,
]);

Serializer<ItemShipModuleCreateTypeEnum>
    _$itemShipModuleCreateTypeEnumSerializer =
    _$ItemShipModuleCreateTypeEnumSerializer();

class _$ItemShipModuleCreateTypeEnumSerializer
    implements PrimitiveSerializer<ItemShipModuleCreateTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'SHIP_MODULE': 'SHIP_MODULE',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'SHIP_MODULE': 'SHIP_MODULE',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemShipModuleCreateTypeEnum];
  @override
  final String wireName = 'ItemShipModuleCreateTypeEnum';

  @override
  Object serialize(Serializers serializers, ItemShipModuleCreateTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemShipModuleCreateTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemShipModuleCreateTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ItemShipModuleCreate extends ItemShipModuleCreate {
  @override
  final ItemShipModuleCreateTypeEnum type;
  @override
  final String name;
  @override
  final ShipModuleSlot slot;
  @override
  final String effect;

  factory _$ItemShipModuleCreate(
          [void Function(ItemShipModuleCreateBuilder)? updates]) =>
      (ItemShipModuleCreateBuilder()..update(updates))._build();

  _$ItemShipModuleCreate._(
      {required this.type,
      required this.name,
      required this.slot,
      required this.effect})
      : super._();
  @override
  ItemShipModuleCreate rebuild(
          void Function(ItemShipModuleCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemShipModuleCreateBuilder toBuilder() =>
      ItemShipModuleCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemShipModuleCreate &&
        type == other.type &&
        name == other.name &&
        slot == other.slot &&
        effect == other.effect;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, slot.hashCode);
    _$hash = $jc(_$hash, effect.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ItemShipModuleCreate')
          ..add('type', type)
          ..add('name', name)
          ..add('slot', slot)
          ..add('effect', effect))
        .toString();
  }
}

class ItemShipModuleCreateBuilder
    implements Builder<ItemShipModuleCreate, ItemShipModuleCreateBuilder> {
  _$ItemShipModuleCreate? _$v;

  ItemShipModuleCreateTypeEnum? _type;
  ItemShipModuleCreateTypeEnum? get type => _$this._type;
  set type(ItemShipModuleCreateTypeEnum? type) => _$this._type = type;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ShipModuleSlot? _slot;
  ShipModuleSlot? get slot => _$this._slot;
  set slot(ShipModuleSlot? slot) => _$this._slot = slot;

  String? _effect;
  String? get effect => _$this._effect;
  set effect(String? effect) => _$this._effect = effect;

  ItemShipModuleCreateBuilder() {
    ItemShipModuleCreate._defaults(this);
  }

  ItemShipModuleCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _name = $v.name;
      _slot = $v.slot;
      _effect = $v.effect;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ItemShipModuleCreate other) {
    _$v = other as _$ItemShipModuleCreate;
  }

  @override
  void update(void Function(ItemShipModuleCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemShipModuleCreate build() => _build();

  _$ItemShipModuleCreate _build() {
    final _$result = _$v ??
        _$ItemShipModuleCreate._(
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'ItemShipModuleCreate', 'type'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'ItemShipModuleCreate', 'name'),
          slot: BuiltValueNullFieldError.checkNotNull(
              slot, r'ItemShipModuleCreate', 'slot'),
          effect: BuiltValueNullFieldError.checkNotNull(
              effect, r'ItemShipModuleCreate', 'effect'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
