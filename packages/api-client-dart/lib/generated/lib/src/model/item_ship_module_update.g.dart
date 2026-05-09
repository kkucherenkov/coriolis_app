// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_ship_module_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemShipModuleUpdateTypeEnum _$itemShipModuleUpdateTypeEnum_SHIP_MODULE =
    const ItemShipModuleUpdateTypeEnum._('SHIP_MODULE');

ItemShipModuleUpdateTypeEnum _$itemShipModuleUpdateTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'SHIP_MODULE':
      return _$itemShipModuleUpdateTypeEnum_SHIP_MODULE;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<ItemShipModuleUpdateTypeEnum>
    _$itemShipModuleUpdateTypeEnumValues = new BuiltSet<
        ItemShipModuleUpdateTypeEnum>(const <ItemShipModuleUpdateTypeEnum>[
  _$itemShipModuleUpdateTypeEnum_SHIP_MODULE,
]);

Serializer<ItemShipModuleUpdateTypeEnum>
    _$itemShipModuleUpdateTypeEnumSerializer =
    new _$ItemShipModuleUpdateTypeEnumSerializer();

class _$ItemShipModuleUpdateTypeEnumSerializer
    implements PrimitiveSerializer<ItemShipModuleUpdateTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'SHIP_MODULE': 'SHIP_MODULE',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'SHIP_MODULE': 'SHIP_MODULE',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemShipModuleUpdateTypeEnum];
  @override
  final String wireName = 'ItemShipModuleUpdateTypeEnum';

  @override
  Object serialize(Serializers serializers, ItemShipModuleUpdateTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemShipModuleUpdateTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemShipModuleUpdateTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ItemShipModuleUpdate extends ItemShipModuleUpdate {
  @override
  final ItemShipModuleUpdateTypeEnum? type;
  @override
  final String? name;
  @override
  final ItemSlotType? slot;
  @override
  final String? effect;

  factory _$ItemShipModuleUpdate(
          [void Function(ItemShipModuleUpdateBuilder)? updates]) =>
      (new ItemShipModuleUpdateBuilder()..update(updates))._build();

  _$ItemShipModuleUpdate._({this.type, this.name, this.slot, this.effect})
      : super._();

  @override
  ItemShipModuleUpdate rebuild(
          void Function(ItemShipModuleUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemShipModuleUpdateBuilder toBuilder() =>
      new ItemShipModuleUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemShipModuleUpdate &&
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
    return (newBuiltValueToStringHelper(r'ItemShipModuleUpdate')
          ..add('type', type)
          ..add('name', name)
          ..add('slot', slot)
          ..add('effect', effect))
        .toString();
  }
}

class ItemShipModuleUpdateBuilder
    implements Builder<ItemShipModuleUpdate, ItemShipModuleUpdateBuilder> {
  _$ItemShipModuleUpdate? _$v;

  ItemShipModuleUpdateTypeEnum? _type;
  ItemShipModuleUpdateTypeEnum? get type => _$this._type;
  set type(ItemShipModuleUpdateTypeEnum? type) => _$this._type = type;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ItemSlotType? _slot;
  ItemSlotType? get slot => _$this._slot;
  set slot(ItemSlotType? slot) => _$this._slot = slot;

  String? _effect;
  String? get effect => _$this._effect;
  set effect(String? effect) => _$this._effect = effect;

  ItemShipModuleUpdateBuilder() {
    ItemShipModuleUpdate._defaults(this);
  }

  ItemShipModuleUpdateBuilder get _$this {
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
  void replace(ItemShipModuleUpdate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ItemShipModuleUpdate;
  }

  @override
  void update(void Function(ItemShipModuleUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemShipModuleUpdate build() => _build();

  _$ItemShipModuleUpdate _build() {
    final _$result = _$v ??
        new _$ItemShipModuleUpdate._(
            type: type, name: name, slot: slot, effect: effect);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
