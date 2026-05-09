// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_cybernetic_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemCyberneticUpdateTypeEnum _$itemCyberneticUpdateTypeEnum_CYBERNETIC =
    const ItemCyberneticUpdateTypeEnum._('CYBERNETIC');

ItemCyberneticUpdateTypeEnum _$itemCyberneticUpdateTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'CYBERNETIC':
      return _$itemCyberneticUpdateTypeEnum_CYBERNETIC;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<ItemCyberneticUpdateTypeEnum>
    _$itemCyberneticUpdateTypeEnumValues = new BuiltSet<
        ItemCyberneticUpdateTypeEnum>(const <ItemCyberneticUpdateTypeEnum>[
  _$itemCyberneticUpdateTypeEnum_CYBERNETIC,
]);

Serializer<ItemCyberneticUpdateTypeEnum>
    _$itemCyberneticUpdateTypeEnumSerializer =
    new _$ItemCyberneticUpdateTypeEnumSerializer();

class _$ItemCyberneticUpdateTypeEnumSerializer
    implements PrimitiveSerializer<ItemCyberneticUpdateTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'CYBERNETIC': 'CYBERNETIC',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'CYBERNETIC': 'CYBERNETIC',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemCyberneticUpdateTypeEnum];
  @override
  final String wireName = 'ItemCyberneticUpdateTypeEnum';

  @override
  Object serialize(Serializers serializers, ItemCyberneticUpdateTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemCyberneticUpdateTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemCyberneticUpdateTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ItemCyberneticUpdate extends ItemCyberneticUpdate {
  @override
  final ItemCyberneticUpdateTypeEnum? type;
  @override
  final String? name;
  @override
  final int? bodyPoints;
  @override
  final String? effect;

  factory _$ItemCyberneticUpdate(
          [void Function(ItemCyberneticUpdateBuilder)? updates]) =>
      (new ItemCyberneticUpdateBuilder()..update(updates))._build();

  _$ItemCyberneticUpdate._({this.type, this.name, this.bodyPoints, this.effect})
      : super._();

  @override
  ItemCyberneticUpdate rebuild(
          void Function(ItemCyberneticUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemCyberneticUpdateBuilder toBuilder() =>
      new ItemCyberneticUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemCyberneticUpdate &&
        type == other.type &&
        name == other.name &&
        bodyPoints == other.bodyPoints &&
        effect == other.effect;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, bodyPoints.hashCode);
    _$hash = $jc(_$hash, effect.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ItemCyberneticUpdate')
          ..add('type', type)
          ..add('name', name)
          ..add('bodyPoints', bodyPoints)
          ..add('effect', effect))
        .toString();
  }
}

class ItemCyberneticUpdateBuilder
    implements Builder<ItemCyberneticUpdate, ItemCyberneticUpdateBuilder> {
  _$ItemCyberneticUpdate? _$v;

  ItemCyberneticUpdateTypeEnum? _type;
  ItemCyberneticUpdateTypeEnum? get type => _$this._type;
  set type(ItemCyberneticUpdateTypeEnum? type) => _$this._type = type;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _bodyPoints;
  int? get bodyPoints => _$this._bodyPoints;
  set bodyPoints(int? bodyPoints) => _$this._bodyPoints = bodyPoints;

  String? _effect;
  String? get effect => _$this._effect;
  set effect(String? effect) => _$this._effect = effect;

  ItemCyberneticUpdateBuilder() {
    ItemCyberneticUpdate._defaults(this);
  }

  ItemCyberneticUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _name = $v.name;
      _bodyPoints = $v.bodyPoints;
      _effect = $v.effect;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ItemCyberneticUpdate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ItemCyberneticUpdate;
  }

  @override
  void update(void Function(ItemCyberneticUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemCyberneticUpdate build() => _build();

  _$ItemCyberneticUpdate _build() {
    final _$result = _$v ??
        new _$ItemCyberneticUpdate._(
            type: type, name: name, bodyPoints: bodyPoints, effect: effect);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
