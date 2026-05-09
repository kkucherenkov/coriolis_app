// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_ship_module.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemShipModuleTypeEnum _$itemShipModuleTypeEnum_SHIP_MODULE =
    const ItemShipModuleTypeEnum._('SHIP_MODULE');

ItemShipModuleTypeEnum _$itemShipModuleTypeEnumValueOf(String name) {
  switch (name) {
    case 'SHIP_MODULE':
      return _$itemShipModuleTypeEnum_SHIP_MODULE;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<ItemShipModuleTypeEnum> _$itemShipModuleTypeEnumValues =
    new BuiltSet<ItemShipModuleTypeEnum>(const <ItemShipModuleTypeEnum>[
  _$itemShipModuleTypeEnum_SHIP_MODULE,
]);

Serializer<ItemShipModuleTypeEnum> _$itemShipModuleTypeEnumSerializer =
    new _$ItemShipModuleTypeEnumSerializer();

class _$ItemShipModuleTypeEnumSerializer
    implements PrimitiveSerializer<ItemShipModuleTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'SHIP_MODULE': 'SHIP_MODULE',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'SHIP_MODULE': 'SHIP_MODULE',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemShipModuleTypeEnum];
  @override
  final String wireName = 'ItemShipModuleTypeEnum';

  @override
  Object serialize(Serializers serializers, ItemShipModuleTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemShipModuleTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemShipModuleTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ItemShipModule extends ItemShipModule {
  @override
  final String effect;
  @override
  final ItemSlotType slot;
  @override
  final String id;
  @override
  final String type;
  @override
  final String name;

  factory _$ItemShipModule([void Function(ItemShipModuleBuilder)? updates]) =>
      (new ItemShipModuleBuilder()..update(updates))._build();

  _$ItemShipModule._(
      {required this.effect,
      required this.slot,
      required this.id,
      required this.type,
      required this.name})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(effect, r'ItemShipModule', 'effect');
    BuiltValueNullFieldError.checkNotNull(slot, r'ItemShipModule', 'slot');
    BuiltValueNullFieldError.checkNotNull(id, r'ItemShipModule', 'id');
    BuiltValueNullFieldError.checkNotNull(type, r'ItemShipModule', 'type');
    BuiltValueNullFieldError.checkNotNull(name, r'ItemShipModule', 'name');
  }

  @override
  ItemShipModule rebuild(void Function(ItemShipModuleBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemShipModuleBuilder toBuilder() =>
      new ItemShipModuleBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemShipModule &&
        effect == other.effect &&
        slot == other.slot &&
        id == other.id &&
        type == other.type &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, effect.hashCode);
    _$hash = $jc(_$hash, slot.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ItemShipModule')
          ..add('effect', effect)
          ..add('slot', slot)
          ..add('id', id)
          ..add('type', type)
          ..add('name', name))
        .toString();
  }
}

class ItemShipModuleBuilder
    implements Builder<ItemShipModule, ItemShipModuleBuilder>, ItemBaseBuilder {
  _$ItemShipModule? _$v;

  String? _effect;
  String? get effect => _$this._effect;
  set effect(covariant String? effect) => _$this._effect = effect;

  ItemSlotType? _slot;
  ItemSlotType? get slot => _$this._slot;
  set slot(covariant ItemSlotType? slot) => _$this._slot = slot;

  String? _id;
  String? get id => _$this._id;
  set id(covariant String? id) => _$this._id = id;

  String? _type;
  String? get type => _$this._type;
  set type(covariant String? type) => _$this._type = type;

  String? _name;
  String? get name => _$this._name;
  set name(covariant String? name) => _$this._name = name;

  ItemShipModuleBuilder() {
    ItemShipModule._defaults(this);
  }

  ItemShipModuleBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _effect = $v.effect;
      _slot = $v.slot;
      _id = $v.id;
      _type = $v.type;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant ItemShipModule other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ItemShipModule;
  }

  @override
  void update(void Function(ItemShipModuleBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemShipModule build() => _build();

  _$ItemShipModule _build() {
    final _$result = _$v ??
        new _$ItemShipModule._(
            effect: BuiltValueNullFieldError.checkNotNull(
                effect, r'ItemShipModule', 'effect'),
            slot: BuiltValueNullFieldError.checkNotNull(
                slot, r'ItemShipModule', 'slot'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'ItemShipModule', 'id'),
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'ItemShipModule', 'type'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'ItemShipModule', 'name'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
