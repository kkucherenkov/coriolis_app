// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_armor_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemArmorCreateTypeEnum _$itemArmorCreateTypeEnum_ARMOR =
    const ItemArmorCreateTypeEnum._('ARMOR');

ItemArmorCreateTypeEnum _$itemArmorCreateTypeEnumValueOf(String name) {
  switch (name) {
    case 'ARMOR':
      return _$itemArmorCreateTypeEnum_ARMOR;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ItemArmorCreateTypeEnum> _$itemArmorCreateTypeEnumValues =
    BuiltSet<ItemArmorCreateTypeEnum>(const <ItemArmorCreateTypeEnum>[
  _$itemArmorCreateTypeEnum_ARMOR,
]);

Serializer<ItemArmorCreateTypeEnum> _$itemArmorCreateTypeEnumSerializer =
    _$ItemArmorCreateTypeEnumSerializer();

class _$ItemArmorCreateTypeEnumSerializer
    implements PrimitiveSerializer<ItemArmorCreateTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ARMOR': 'ARMOR',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ARMOR': 'ARMOR',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemArmorCreateTypeEnum];
  @override
  final String wireName = 'ItemArmorCreateTypeEnum';

  @override
  Object serialize(Serializers serializers, ItemArmorCreateTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemArmorCreateTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemArmorCreateTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ItemArmorCreate extends ItemArmorCreate {
  @override
  final ItemArmorCreateTypeEnum type;
  @override
  final String name;
  @override
  final int armorRating;
  @override
  final num weight;
  @override
  final BuiltList<String> features;
  @override
  final bool equipped;
  @override
  final int? extraSlotCount;

  factory _$ItemArmorCreate([void Function(ItemArmorCreateBuilder)? updates]) =>
      (ItemArmorCreateBuilder()..update(updates))._build();

  _$ItemArmorCreate._(
      {required this.type,
      required this.name,
      required this.armorRating,
      required this.weight,
      required this.features,
      required this.equipped,
      this.extraSlotCount})
      : super._();
  @override
  ItemArmorCreate rebuild(void Function(ItemArmorCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemArmorCreateBuilder toBuilder() => ItemArmorCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemArmorCreate &&
        type == other.type &&
        name == other.name &&
        armorRating == other.armorRating &&
        weight == other.weight &&
        features == other.features &&
        equipped == other.equipped &&
        extraSlotCount == other.extraSlotCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, armorRating.hashCode);
    _$hash = $jc(_$hash, weight.hashCode);
    _$hash = $jc(_$hash, features.hashCode);
    _$hash = $jc(_$hash, equipped.hashCode);
    _$hash = $jc(_$hash, extraSlotCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ItemArmorCreate')
          ..add('type', type)
          ..add('name', name)
          ..add('armorRating', armorRating)
          ..add('weight', weight)
          ..add('features', features)
          ..add('equipped', equipped)
          ..add('extraSlotCount', extraSlotCount))
        .toString();
  }
}

class ItemArmorCreateBuilder
    implements Builder<ItemArmorCreate, ItemArmorCreateBuilder> {
  _$ItemArmorCreate? _$v;

  ItemArmorCreateTypeEnum? _type;
  ItemArmorCreateTypeEnum? get type => _$this._type;
  set type(ItemArmorCreateTypeEnum? type) => _$this._type = type;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _armorRating;
  int? get armorRating => _$this._armorRating;
  set armorRating(int? armorRating) => _$this._armorRating = armorRating;

  num? _weight;
  num? get weight => _$this._weight;
  set weight(num? weight) => _$this._weight = weight;

  ListBuilder<String>? _features;
  ListBuilder<String> get features =>
      _$this._features ??= ListBuilder<String>();
  set features(ListBuilder<String>? features) => _$this._features = features;

  bool? _equipped;
  bool? get equipped => _$this._equipped;
  set equipped(bool? equipped) => _$this._equipped = equipped;

  int? _extraSlotCount;
  int? get extraSlotCount => _$this._extraSlotCount;
  set extraSlotCount(int? extraSlotCount) =>
      _$this._extraSlotCount = extraSlotCount;

  ItemArmorCreateBuilder() {
    ItemArmorCreate._defaults(this);
  }

  ItemArmorCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _name = $v.name;
      _armorRating = $v.armorRating;
      _weight = $v.weight;
      _features = $v.features.toBuilder();
      _equipped = $v.equipped;
      _extraSlotCount = $v.extraSlotCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ItemArmorCreate other) {
    _$v = other as _$ItemArmorCreate;
  }

  @override
  void update(void Function(ItemArmorCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemArmorCreate build() => _build();

  _$ItemArmorCreate _build() {
    _$ItemArmorCreate _$result;
    try {
      _$result = _$v ??
          _$ItemArmorCreate._(
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'ItemArmorCreate', 'type'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'ItemArmorCreate', 'name'),
            armorRating: BuiltValueNullFieldError.checkNotNull(
                armorRating, r'ItemArmorCreate', 'armorRating'),
            weight: BuiltValueNullFieldError.checkNotNull(
                weight, r'ItemArmorCreate', 'weight'),
            features: features.build(),
            equipped: BuiltValueNullFieldError.checkNotNull(
                equipped, r'ItemArmorCreate', 'equipped'),
            extraSlotCount: extraSlotCount,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'features';
        features.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ItemArmorCreate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
