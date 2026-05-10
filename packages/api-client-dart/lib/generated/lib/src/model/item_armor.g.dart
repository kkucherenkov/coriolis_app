// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_armor.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemArmorTypeEnum _$itemArmorTypeEnum_ARMOR = const ItemArmorTypeEnum._(
  'ARMOR',
);

ItemArmorTypeEnum _$itemArmorTypeEnumValueOf(String name) {
  switch (name) {
    case 'ARMOR':
      return _$itemArmorTypeEnum_ARMOR;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ItemArmorTypeEnum> _$itemArmorTypeEnumValues =
    BuiltSet<ItemArmorTypeEnum>(const <ItemArmorTypeEnum>[
      _$itemArmorTypeEnum_ARMOR,
    ]);

Serializer<ItemArmorTypeEnum> _$itemArmorTypeEnumSerializer =
    _$ItemArmorTypeEnumSerializer();

class _$ItemArmorTypeEnumSerializer
    implements PrimitiveSerializer<ItemArmorTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ARMOR': 'ARMOR',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ARMOR': 'ARMOR',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemArmorTypeEnum];
  @override
  final String wireName = 'ItemArmorTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ItemArmorTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ItemArmorTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ItemArmorTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ItemArmor extends ItemArmor {
  @override
  final BuiltList<String> features;
  @override
  final bool equipped;
  @override
  final num weight;
  @override
  final int armorRating;

  factory _$ItemArmor([void Function(ItemArmorBuilder)? updates]) =>
      (ItemArmorBuilder()..update(updates))._build();

  _$ItemArmor._({
    required this.features,
    required this.equipped,
    required this.weight,
    required this.armorRating,
  }) : super._();
  @override
  ItemArmor rebuild(void Function(ItemArmorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemArmorBuilder toBuilder() => ItemArmorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemArmor &&
        features == other.features &&
        equipped == other.equipped &&
        weight == other.weight &&
        armorRating == other.armorRating;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, features.hashCode);
    _$hash = $jc(_$hash, equipped.hashCode);
    _$hash = $jc(_$hash, weight.hashCode);
    _$hash = $jc(_$hash, armorRating.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ItemArmor')
          ..add('features', features)
          ..add('equipped', equipped)
          ..add('weight', weight)
          ..add('armorRating', armorRating))
        .toString();
  }
}

class ItemArmorBuilder implements Builder<ItemArmor, ItemArmorBuilder> {
  _$ItemArmor? _$v;

  ListBuilder<String>? _features;
  ListBuilder<String> get features =>
      _$this._features ??= ListBuilder<String>();
  set features(ListBuilder<String>? features) => _$this._features = features;

  bool? _equipped;
  bool? get equipped => _$this._equipped;
  set equipped(bool? equipped) => _$this._equipped = equipped;

  num? _weight;
  num? get weight => _$this._weight;
  set weight(num? weight) => _$this._weight = weight;

  int? _armorRating;
  int? get armorRating => _$this._armorRating;
  set armorRating(int? armorRating) => _$this._armorRating = armorRating;

  ItemArmorBuilder() {
    ItemArmor._defaults(this);
  }

  ItemArmorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _features = $v.features.toBuilder();
      _equipped = $v.equipped;
      _weight = $v.weight;
      _armorRating = $v.armorRating;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ItemArmor other) {
    _$v = other as _$ItemArmor;
  }

  @override
  void update(void Function(ItemArmorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemArmor build() => _build();

  _$ItemArmor _build() {
    _$ItemArmor _$result;
    try {
      _$result =
          _$v ??
          _$ItemArmor._(
            features: features.build(),
            equipped: BuiltValueNullFieldError.checkNotNull(
              equipped,
              r'ItemArmor',
              'equipped',
            ),
            weight: BuiltValueNullFieldError.checkNotNull(
              weight,
              r'ItemArmor',
              'weight',
            ),
            armorRating: BuiltValueNullFieldError.checkNotNull(
              armorRating,
              r'ItemArmor',
              'armorRating',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'features';
        features.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ItemArmor',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
