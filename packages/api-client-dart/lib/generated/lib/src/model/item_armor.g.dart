// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_armor.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemArmorTypeEnum _$itemArmorTypeEnum_ARMOR =
    const ItemArmorTypeEnum._('ARMOR');

ItemArmorTypeEnum _$itemArmorTypeEnumValueOf(String name) {
  switch (name) {
    case 'ARMOR':
      return _$itemArmorTypeEnum_ARMOR;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<ItemArmorTypeEnum> _$itemArmorTypeEnumValues =
    new BuiltSet<ItemArmorTypeEnum>(const <ItemArmorTypeEnum>[
  _$itemArmorTypeEnum_ARMOR,
]);

Serializer<ItemArmorTypeEnum> _$itemArmorTypeEnumSerializer =
    new _$ItemArmorTypeEnumSerializer();

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
  Object serialize(Serializers serializers, ItemArmorTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemArmorTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemArmorTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
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
  @override
  final String id;
  @override
  final String type;
  @override
  final String name;

  factory _$ItemArmor([void Function(ItemArmorBuilder)? updates]) =>
      (new ItemArmorBuilder()..update(updates))._build();

  _$ItemArmor._(
      {required this.features,
      required this.equipped,
      required this.weight,
      required this.armorRating,
      required this.id,
      required this.type,
      required this.name})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(features, r'ItemArmor', 'features');
    BuiltValueNullFieldError.checkNotNull(equipped, r'ItemArmor', 'equipped');
    BuiltValueNullFieldError.checkNotNull(weight, r'ItemArmor', 'weight');
    BuiltValueNullFieldError.checkNotNull(
        armorRating, r'ItemArmor', 'armorRating');
    BuiltValueNullFieldError.checkNotNull(id, r'ItemArmor', 'id');
    BuiltValueNullFieldError.checkNotNull(type, r'ItemArmor', 'type');
    BuiltValueNullFieldError.checkNotNull(name, r'ItemArmor', 'name');
  }

  @override
  ItemArmor rebuild(void Function(ItemArmorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemArmorBuilder toBuilder() => new ItemArmorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemArmor &&
        features == other.features &&
        equipped == other.equipped &&
        weight == other.weight &&
        armorRating == other.armorRating &&
        id == other.id &&
        type == other.type &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, features.hashCode);
    _$hash = $jc(_$hash, equipped.hashCode);
    _$hash = $jc(_$hash, weight.hashCode);
    _$hash = $jc(_$hash, armorRating.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ItemArmor')
          ..add('features', features)
          ..add('equipped', equipped)
          ..add('weight', weight)
          ..add('armorRating', armorRating)
          ..add('id', id)
          ..add('type', type)
          ..add('name', name))
        .toString();
  }
}

class ItemArmorBuilder
    implements Builder<ItemArmor, ItemArmorBuilder>, ItemBaseBuilder {
  _$ItemArmor? _$v;

  ListBuilder<String>? _features;
  ListBuilder<String> get features =>
      _$this._features ??= new ListBuilder<String>();
  set features(covariant ListBuilder<String>? features) =>
      _$this._features = features;

  bool? _equipped;
  bool? get equipped => _$this._equipped;
  set equipped(covariant bool? equipped) => _$this._equipped = equipped;

  num? _weight;
  num? get weight => _$this._weight;
  set weight(covariant num? weight) => _$this._weight = weight;

  int? _armorRating;
  int? get armorRating => _$this._armorRating;
  set armorRating(covariant int? armorRating) =>
      _$this._armorRating = armorRating;

  String? _id;
  String? get id => _$this._id;
  set id(covariant String? id) => _$this._id = id;

  String? _type;
  String? get type => _$this._type;
  set type(covariant String? type) => _$this._type = type;

  String? _name;
  String? get name => _$this._name;
  set name(covariant String? name) => _$this._name = name;

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
      _id = $v.id;
      _type = $v.type;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant ItemArmor other) {
    ArgumentError.checkNotNull(other, 'other');
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
      _$result = _$v ??
          new _$ItemArmor._(
              features: features.build(),
              equipped: BuiltValueNullFieldError.checkNotNull(
                  equipped, r'ItemArmor', 'equipped'),
              weight: BuiltValueNullFieldError.checkNotNull(
                  weight, r'ItemArmor', 'weight'),
              armorRating: BuiltValueNullFieldError.checkNotNull(
                  armorRating, r'ItemArmor', 'armorRating'),
              id: BuiltValueNullFieldError.checkNotNull(id, r'ItemArmor', 'id'),
              type: BuiltValueNullFieldError.checkNotNull(
                  type, r'ItemArmor', 'type'),
              name: BuiltValueNullFieldError.checkNotNull(
                  name, r'ItemArmor', 'name'));
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'features';
        features.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'ItemArmor', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
