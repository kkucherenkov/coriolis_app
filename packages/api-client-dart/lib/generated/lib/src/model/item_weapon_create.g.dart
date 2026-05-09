// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_weapon_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemWeaponCreateTypeEnum _$itemWeaponCreateTypeEnum_WEAPON =
    const ItemWeaponCreateTypeEnum._('WEAPON');

ItemWeaponCreateTypeEnum _$itemWeaponCreateTypeEnumValueOf(String name) {
  switch (name) {
    case 'WEAPON':
      return _$itemWeaponCreateTypeEnum_WEAPON;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<ItemWeaponCreateTypeEnum> _$itemWeaponCreateTypeEnumValues =
    new BuiltSet<ItemWeaponCreateTypeEnum>(const <ItemWeaponCreateTypeEnum>[
  _$itemWeaponCreateTypeEnum_WEAPON,
]);

Serializer<ItemWeaponCreateTypeEnum> _$itemWeaponCreateTypeEnumSerializer =
    new _$ItemWeaponCreateTypeEnumSerializer();

class _$ItemWeaponCreateTypeEnumSerializer
    implements PrimitiveSerializer<ItemWeaponCreateTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'WEAPON': 'WEAPON',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'WEAPON': 'WEAPON',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemWeaponCreateTypeEnum];
  @override
  final String wireName = 'ItemWeaponCreateTypeEnum';

  @override
  Object serialize(Serializers serializers, ItemWeaponCreateTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemWeaponCreateTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemWeaponCreateTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ItemWeaponCreate extends ItemWeaponCreate {
  @override
  final ItemWeaponCreateTypeEnum type;
  @override
  final String name;
  @override
  final int damage;
  @override
  final ItemRangeEnum range;
  @override
  final int bonus;
  @override
  final int crit;
  @override
  final num weight;
  @override
  final BuiltList<String> features;
  @override
  final bool equipped;

  factory _$ItemWeaponCreate(
          [void Function(ItemWeaponCreateBuilder)? updates]) =>
      (new ItemWeaponCreateBuilder()..update(updates))._build();

  _$ItemWeaponCreate._(
      {required this.type,
      required this.name,
      required this.damage,
      required this.range,
      required this.bonus,
      required this.crit,
      required this.weight,
      required this.features,
      required this.equipped})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(type, r'ItemWeaponCreate', 'type');
    BuiltValueNullFieldError.checkNotNull(name, r'ItemWeaponCreate', 'name');
    BuiltValueNullFieldError.checkNotNull(
        damage, r'ItemWeaponCreate', 'damage');
    BuiltValueNullFieldError.checkNotNull(range, r'ItemWeaponCreate', 'range');
    BuiltValueNullFieldError.checkNotNull(bonus, r'ItemWeaponCreate', 'bonus');
    BuiltValueNullFieldError.checkNotNull(crit, r'ItemWeaponCreate', 'crit');
    BuiltValueNullFieldError.checkNotNull(
        weight, r'ItemWeaponCreate', 'weight');
    BuiltValueNullFieldError.checkNotNull(
        features, r'ItemWeaponCreate', 'features');
    BuiltValueNullFieldError.checkNotNull(
        equipped, r'ItemWeaponCreate', 'equipped');
  }

  @override
  ItemWeaponCreate rebuild(void Function(ItemWeaponCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemWeaponCreateBuilder toBuilder() =>
      new ItemWeaponCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemWeaponCreate &&
        type == other.type &&
        name == other.name &&
        damage == other.damage &&
        range == other.range &&
        bonus == other.bonus &&
        crit == other.crit &&
        weight == other.weight &&
        features == other.features &&
        equipped == other.equipped;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, damage.hashCode);
    _$hash = $jc(_$hash, range.hashCode);
    _$hash = $jc(_$hash, bonus.hashCode);
    _$hash = $jc(_$hash, crit.hashCode);
    _$hash = $jc(_$hash, weight.hashCode);
    _$hash = $jc(_$hash, features.hashCode);
    _$hash = $jc(_$hash, equipped.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ItemWeaponCreate')
          ..add('type', type)
          ..add('name', name)
          ..add('damage', damage)
          ..add('range', range)
          ..add('bonus', bonus)
          ..add('crit', crit)
          ..add('weight', weight)
          ..add('features', features)
          ..add('equipped', equipped))
        .toString();
  }
}

class ItemWeaponCreateBuilder
    implements Builder<ItemWeaponCreate, ItemWeaponCreateBuilder> {
  _$ItemWeaponCreate? _$v;

  ItemWeaponCreateTypeEnum? _type;
  ItemWeaponCreateTypeEnum? get type => _$this._type;
  set type(ItemWeaponCreateTypeEnum? type) => _$this._type = type;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _damage;
  int? get damage => _$this._damage;
  set damage(int? damage) => _$this._damage = damage;

  ItemRangeEnum? _range;
  ItemRangeEnum? get range => _$this._range;
  set range(ItemRangeEnum? range) => _$this._range = range;

  int? _bonus;
  int? get bonus => _$this._bonus;
  set bonus(int? bonus) => _$this._bonus = bonus;

  int? _crit;
  int? get crit => _$this._crit;
  set crit(int? crit) => _$this._crit = crit;

  num? _weight;
  num? get weight => _$this._weight;
  set weight(num? weight) => _$this._weight = weight;

  ListBuilder<String>? _features;
  ListBuilder<String> get features =>
      _$this._features ??= new ListBuilder<String>();
  set features(ListBuilder<String>? features) => _$this._features = features;

  bool? _equipped;
  bool? get equipped => _$this._equipped;
  set equipped(bool? equipped) => _$this._equipped = equipped;

  ItemWeaponCreateBuilder() {
    ItemWeaponCreate._defaults(this);
  }

  ItemWeaponCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _name = $v.name;
      _damage = $v.damage;
      _range = $v.range;
      _bonus = $v.bonus;
      _crit = $v.crit;
      _weight = $v.weight;
      _features = $v.features.toBuilder();
      _equipped = $v.equipped;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ItemWeaponCreate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ItemWeaponCreate;
  }

  @override
  void update(void Function(ItemWeaponCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemWeaponCreate build() => _build();

  _$ItemWeaponCreate _build() {
    _$ItemWeaponCreate _$result;
    try {
      _$result = _$v ??
          new _$ItemWeaponCreate._(
              type: BuiltValueNullFieldError.checkNotNull(
                  type, r'ItemWeaponCreate', 'type'),
              name: BuiltValueNullFieldError.checkNotNull(
                  name, r'ItemWeaponCreate', 'name'),
              damage: BuiltValueNullFieldError.checkNotNull(
                  damage, r'ItemWeaponCreate', 'damage'),
              range: BuiltValueNullFieldError.checkNotNull(
                  range, r'ItemWeaponCreate', 'range'),
              bonus: BuiltValueNullFieldError.checkNotNull(
                  bonus, r'ItemWeaponCreate', 'bonus'),
              crit: BuiltValueNullFieldError.checkNotNull(
                  crit, r'ItemWeaponCreate', 'crit'),
              weight: BuiltValueNullFieldError.checkNotNull(
                  weight, r'ItemWeaponCreate', 'weight'),
              features: features.build(),
              equipped: BuiltValueNullFieldError.checkNotNull(
                  equipped, r'ItemWeaponCreate', 'equipped'));
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'features';
        features.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'ItemWeaponCreate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
