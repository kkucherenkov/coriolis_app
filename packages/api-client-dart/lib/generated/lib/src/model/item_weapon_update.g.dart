// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_weapon_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemWeaponUpdateTypeEnum _$itemWeaponUpdateTypeEnum_WEAPON =
    const ItemWeaponUpdateTypeEnum._('WEAPON');

ItemWeaponUpdateTypeEnum _$itemWeaponUpdateTypeEnumValueOf(String name) {
  switch (name) {
    case 'WEAPON':
      return _$itemWeaponUpdateTypeEnum_WEAPON;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ItemWeaponUpdateTypeEnum> _$itemWeaponUpdateTypeEnumValues =
    BuiltSet<ItemWeaponUpdateTypeEnum>(const <ItemWeaponUpdateTypeEnum>[
  _$itemWeaponUpdateTypeEnum_WEAPON,
]);

Serializer<ItemWeaponUpdateTypeEnum> _$itemWeaponUpdateTypeEnumSerializer =
    _$ItemWeaponUpdateTypeEnumSerializer();

class _$ItemWeaponUpdateTypeEnumSerializer
    implements PrimitiveSerializer<ItemWeaponUpdateTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'WEAPON': 'WEAPON',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'WEAPON': 'WEAPON',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemWeaponUpdateTypeEnum];
  @override
  final String wireName = 'ItemWeaponUpdateTypeEnum';

  @override
  Object serialize(Serializers serializers, ItemWeaponUpdateTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemWeaponUpdateTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemWeaponUpdateTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ItemWeaponUpdate extends ItemWeaponUpdate {
  @override
  final ItemWeaponUpdateTypeEnum? type;
  @override
  final String? name;
  @override
  final int? damage;
  @override
  final ItemRangeEnum? range;
  @override
  final int? bonus;
  @override
  final int? crit;
  @override
  final num? weight;
  @override
  final BuiltList<String>? features;
  @override
  final bool? equipped;
  @override
  final int? initiative;

  factory _$ItemWeaponUpdate(
          [void Function(ItemWeaponUpdateBuilder)? updates]) =>
      (ItemWeaponUpdateBuilder()..update(updates))._build();

  _$ItemWeaponUpdate._(
      {this.type,
      this.name,
      this.damage,
      this.range,
      this.bonus,
      this.crit,
      this.weight,
      this.features,
      this.equipped,
      this.initiative})
      : super._();
  @override
  ItemWeaponUpdate rebuild(void Function(ItemWeaponUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemWeaponUpdateBuilder toBuilder() =>
      ItemWeaponUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemWeaponUpdate &&
        type == other.type &&
        name == other.name &&
        damage == other.damage &&
        range == other.range &&
        bonus == other.bonus &&
        crit == other.crit &&
        weight == other.weight &&
        features == other.features &&
        equipped == other.equipped &&
        initiative == other.initiative;
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
    _$hash = $jc(_$hash, initiative.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ItemWeaponUpdate')
          ..add('type', type)
          ..add('name', name)
          ..add('damage', damage)
          ..add('range', range)
          ..add('bonus', bonus)
          ..add('crit', crit)
          ..add('weight', weight)
          ..add('features', features)
          ..add('equipped', equipped)
          ..add('initiative', initiative))
        .toString();
  }
}

class ItemWeaponUpdateBuilder
    implements Builder<ItemWeaponUpdate, ItemWeaponUpdateBuilder> {
  _$ItemWeaponUpdate? _$v;

  ItemWeaponUpdateTypeEnum? _type;
  ItemWeaponUpdateTypeEnum? get type => _$this._type;
  set type(ItemWeaponUpdateTypeEnum? type) => _$this._type = type;

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
      _$this._features ??= ListBuilder<String>();
  set features(ListBuilder<String>? features) => _$this._features = features;

  bool? _equipped;
  bool? get equipped => _$this._equipped;
  set equipped(bool? equipped) => _$this._equipped = equipped;

  int? _initiative;
  int? get initiative => _$this._initiative;
  set initiative(int? initiative) => _$this._initiative = initiative;

  ItemWeaponUpdateBuilder() {
    ItemWeaponUpdate._defaults(this);
  }

  ItemWeaponUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _name = $v.name;
      _damage = $v.damage;
      _range = $v.range;
      _bonus = $v.bonus;
      _crit = $v.crit;
      _weight = $v.weight;
      _features = $v.features?.toBuilder();
      _equipped = $v.equipped;
      _initiative = $v.initiative;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ItemWeaponUpdate other) {
    _$v = other as _$ItemWeaponUpdate;
  }

  @override
  void update(void Function(ItemWeaponUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemWeaponUpdate build() => _build();

  _$ItemWeaponUpdate _build() {
    _$ItemWeaponUpdate _$result;
    try {
      _$result = _$v ??
          _$ItemWeaponUpdate._(
            type: type,
            name: name,
            damage: damage,
            range: range,
            bonus: bonus,
            crit: crit,
            weight: weight,
            features: _features?.build(),
            equipped: equipped,
            initiative: initiative,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'features';
        _features?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ItemWeaponUpdate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
