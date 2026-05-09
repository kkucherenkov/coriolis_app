// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_weapon.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemWeaponTypeEnum _$itemWeaponTypeEnum_WEAPON =
    const ItemWeaponTypeEnum._('WEAPON');

ItemWeaponTypeEnum _$itemWeaponTypeEnumValueOf(String name) {
  switch (name) {
    case 'WEAPON':
      return _$itemWeaponTypeEnum_WEAPON;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<ItemWeaponTypeEnum> _$itemWeaponTypeEnumValues =
    new BuiltSet<ItemWeaponTypeEnum>(const <ItemWeaponTypeEnum>[
  _$itemWeaponTypeEnum_WEAPON,
]);

Serializer<ItemWeaponTypeEnum> _$itemWeaponTypeEnumSerializer =
    new _$ItemWeaponTypeEnumSerializer();

class _$ItemWeaponTypeEnumSerializer
    implements PrimitiveSerializer<ItemWeaponTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'WEAPON': 'WEAPON',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'WEAPON': 'WEAPON',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemWeaponTypeEnum];
  @override
  final String wireName = 'ItemWeaponTypeEnum';

  @override
  Object serialize(Serializers serializers, ItemWeaponTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemWeaponTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemWeaponTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ItemWeapon extends ItemWeapon {
  @override
  final int damage;
  @override
  final BuiltList<String> features;
  @override
  final int crit;
  @override
  final bool equipped;
  @override
  final int bonus;
  @override
  final ItemRangeEnum range;
  @override
  final num weight;
  @override
  final String id;
  @override
  final String type;
  @override
  final String name;

  factory _$ItemWeapon([void Function(ItemWeaponBuilder)? updates]) =>
      (new ItemWeaponBuilder()..update(updates))._build();

  _$ItemWeapon._(
      {required this.damage,
      required this.features,
      required this.crit,
      required this.equipped,
      required this.bonus,
      required this.range,
      required this.weight,
      required this.id,
      required this.type,
      required this.name})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(damage, r'ItemWeapon', 'damage');
    BuiltValueNullFieldError.checkNotNull(features, r'ItemWeapon', 'features');
    BuiltValueNullFieldError.checkNotNull(crit, r'ItemWeapon', 'crit');
    BuiltValueNullFieldError.checkNotNull(equipped, r'ItemWeapon', 'equipped');
    BuiltValueNullFieldError.checkNotNull(bonus, r'ItemWeapon', 'bonus');
    BuiltValueNullFieldError.checkNotNull(range, r'ItemWeapon', 'range');
    BuiltValueNullFieldError.checkNotNull(weight, r'ItemWeapon', 'weight');
    BuiltValueNullFieldError.checkNotNull(id, r'ItemWeapon', 'id');
    BuiltValueNullFieldError.checkNotNull(type, r'ItemWeapon', 'type');
    BuiltValueNullFieldError.checkNotNull(name, r'ItemWeapon', 'name');
  }

  @override
  ItemWeapon rebuild(void Function(ItemWeaponBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemWeaponBuilder toBuilder() => new ItemWeaponBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemWeapon &&
        damage == other.damage &&
        features == other.features &&
        crit == other.crit &&
        equipped == other.equipped &&
        bonus == other.bonus &&
        range == other.range &&
        weight == other.weight &&
        id == other.id &&
        type == other.type &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, damage.hashCode);
    _$hash = $jc(_$hash, features.hashCode);
    _$hash = $jc(_$hash, crit.hashCode);
    _$hash = $jc(_$hash, equipped.hashCode);
    _$hash = $jc(_$hash, bonus.hashCode);
    _$hash = $jc(_$hash, range.hashCode);
    _$hash = $jc(_$hash, weight.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ItemWeapon')
          ..add('damage', damage)
          ..add('features', features)
          ..add('crit', crit)
          ..add('equipped', equipped)
          ..add('bonus', bonus)
          ..add('range', range)
          ..add('weight', weight)
          ..add('id', id)
          ..add('type', type)
          ..add('name', name))
        .toString();
  }
}

class ItemWeaponBuilder
    implements Builder<ItemWeapon, ItemWeaponBuilder>, ItemBaseBuilder {
  _$ItemWeapon? _$v;

  int? _damage;
  int? get damage => _$this._damage;
  set damage(covariant int? damage) => _$this._damage = damage;

  ListBuilder<String>? _features;
  ListBuilder<String> get features =>
      _$this._features ??= new ListBuilder<String>();
  set features(covariant ListBuilder<String>? features) =>
      _$this._features = features;

  int? _crit;
  int? get crit => _$this._crit;
  set crit(covariant int? crit) => _$this._crit = crit;

  bool? _equipped;
  bool? get equipped => _$this._equipped;
  set equipped(covariant bool? equipped) => _$this._equipped = equipped;

  int? _bonus;
  int? get bonus => _$this._bonus;
  set bonus(covariant int? bonus) => _$this._bonus = bonus;

  ItemRangeEnum? _range;
  ItemRangeEnum? get range => _$this._range;
  set range(covariant ItemRangeEnum? range) => _$this._range = range;

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

  ItemWeaponBuilder() {
    ItemWeapon._defaults(this);
  }

  ItemWeaponBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _damage = $v.damage;
      _features = $v.features.toBuilder();
      _crit = $v.crit;
      _equipped = $v.equipped;
      _bonus = $v.bonus;
      _range = $v.range;
      _weight = $v.weight;
      _id = $v.id;
      _type = $v.type;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant ItemWeapon other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ItemWeapon;
  }

  @override
  void update(void Function(ItemWeaponBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemWeapon build() => _build();

  _$ItemWeapon _build() {
    _$ItemWeapon _$result;
    try {
      _$result = _$v ??
          new _$ItemWeapon._(
              damage: BuiltValueNullFieldError.checkNotNull(
                  damage, r'ItemWeapon', 'damage'),
              features: features.build(),
              crit: BuiltValueNullFieldError.checkNotNull(
                  crit, r'ItemWeapon', 'crit'),
              equipped: BuiltValueNullFieldError.checkNotNull(
                  equipped, r'ItemWeapon', 'equipped'),
              bonus: BuiltValueNullFieldError.checkNotNull(
                  bonus, r'ItemWeapon', 'bonus'),
              range: BuiltValueNullFieldError.checkNotNull(
                  range, r'ItemWeapon', 'range'),
              weight: BuiltValueNullFieldError.checkNotNull(
                  weight, r'ItemWeapon', 'weight'),
              id: BuiltValueNullFieldError.checkNotNull(
                  id, r'ItemWeapon', 'id'),
              type: BuiltValueNullFieldError.checkNotNull(
                  type, r'ItemWeapon', 'type'),
              name: BuiltValueNullFieldError.checkNotNull(
                  name, r'ItemWeapon', 'name'));
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'features';
        features.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'ItemWeapon', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
