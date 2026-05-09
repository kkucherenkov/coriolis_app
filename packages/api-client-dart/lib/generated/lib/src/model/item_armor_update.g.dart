// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_armor_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemArmorUpdateTypeEnum _$itemArmorUpdateTypeEnum_ARMOR =
    const ItemArmorUpdateTypeEnum._('ARMOR');

ItemArmorUpdateTypeEnum _$itemArmorUpdateTypeEnumValueOf(String name) {
  switch (name) {
    case 'ARMOR':
      return _$itemArmorUpdateTypeEnum_ARMOR;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<ItemArmorUpdateTypeEnum> _$itemArmorUpdateTypeEnumValues =
    new BuiltSet<ItemArmorUpdateTypeEnum>(const <ItemArmorUpdateTypeEnum>[
  _$itemArmorUpdateTypeEnum_ARMOR,
]);

Serializer<ItemArmorUpdateTypeEnum> _$itemArmorUpdateTypeEnumSerializer =
    new _$ItemArmorUpdateTypeEnumSerializer();

class _$ItemArmorUpdateTypeEnumSerializer
    implements PrimitiveSerializer<ItemArmorUpdateTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ARMOR': 'ARMOR',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ARMOR': 'ARMOR',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemArmorUpdateTypeEnum];
  @override
  final String wireName = 'ItemArmorUpdateTypeEnum';

  @override
  Object serialize(Serializers serializers, ItemArmorUpdateTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemArmorUpdateTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemArmorUpdateTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ItemArmorUpdate extends ItemArmorUpdate {
  @override
  final ItemArmorUpdateTypeEnum? type;
  @override
  final String? name;
  @override
  final int? armorRating;
  @override
  final num? weight;
  @override
  final BuiltList<String>? features;
  @override
  final bool? equipped;

  factory _$ItemArmorUpdate([void Function(ItemArmorUpdateBuilder)? updates]) =>
      (new ItemArmorUpdateBuilder()..update(updates))._build();

  _$ItemArmorUpdate._(
      {this.type,
      this.name,
      this.armorRating,
      this.weight,
      this.features,
      this.equipped})
      : super._();

  @override
  ItemArmorUpdate rebuild(void Function(ItemArmorUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemArmorUpdateBuilder toBuilder() =>
      new ItemArmorUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemArmorUpdate &&
        type == other.type &&
        name == other.name &&
        armorRating == other.armorRating &&
        weight == other.weight &&
        features == other.features &&
        equipped == other.equipped;
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
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ItemArmorUpdate')
          ..add('type', type)
          ..add('name', name)
          ..add('armorRating', armorRating)
          ..add('weight', weight)
          ..add('features', features)
          ..add('equipped', equipped))
        .toString();
  }
}

class ItemArmorUpdateBuilder
    implements Builder<ItemArmorUpdate, ItemArmorUpdateBuilder> {
  _$ItemArmorUpdate? _$v;

  ItemArmorUpdateTypeEnum? _type;
  ItemArmorUpdateTypeEnum? get type => _$this._type;
  set type(ItemArmorUpdateTypeEnum? type) => _$this._type = type;

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
      _$this._features ??= new ListBuilder<String>();
  set features(ListBuilder<String>? features) => _$this._features = features;

  bool? _equipped;
  bool? get equipped => _$this._equipped;
  set equipped(bool? equipped) => _$this._equipped = equipped;

  ItemArmorUpdateBuilder() {
    ItemArmorUpdate._defaults(this);
  }

  ItemArmorUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _name = $v.name;
      _armorRating = $v.armorRating;
      _weight = $v.weight;
      _features = $v.features?.toBuilder();
      _equipped = $v.equipped;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ItemArmorUpdate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ItemArmorUpdate;
  }

  @override
  void update(void Function(ItemArmorUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemArmorUpdate build() => _build();

  _$ItemArmorUpdate _build() {
    _$ItemArmorUpdate _$result;
    try {
      _$result = _$v ??
          new _$ItemArmorUpdate._(
              type: type,
              name: name,
              armorRating: armorRating,
              weight: weight,
              features: _features?.build(),
              equipped: equipped);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'features';
        _features?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'ItemArmorUpdate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
