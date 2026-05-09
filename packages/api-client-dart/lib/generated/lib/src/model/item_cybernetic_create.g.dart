// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_cybernetic_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemCyberneticCreateTypeEnum _$itemCyberneticCreateTypeEnum_CYBERNETIC =
    const ItemCyberneticCreateTypeEnum._('CYBERNETIC');

ItemCyberneticCreateTypeEnum _$itemCyberneticCreateTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'CYBERNETIC':
      return _$itemCyberneticCreateTypeEnum_CYBERNETIC;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<ItemCyberneticCreateTypeEnum>
    _$itemCyberneticCreateTypeEnumValues = new BuiltSet<
        ItemCyberneticCreateTypeEnum>(const <ItemCyberneticCreateTypeEnum>[
  _$itemCyberneticCreateTypeEnum_CYBERNETIC,
]);

Serializer<ItemCyberneticCreateTypeEnum>
    _$itemCyberneticCreateTypeEnumSerializer =
    new _$ItemCyberneticCreateTypeEnumSerializer();

class _$ItemCyberneticCreateTypeEnumSerializer
    implements PrimitiveSerializer<ItemCyberneticCreateTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'CYBERNETIC': 'CYBERNETIC',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'CYBERNETIC': 'CYBERNETIC',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemCyberneticCreateTypeEnum];
  @override
  final String wireName = 'ItemCyberneticCreateTypeEnum';

  @override
  Object serialize(Serializers serializers, ItemCyberneticCreateTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemCyberneticCreateTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemCyberneticCreateTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ItemCyberneticCreate extends ItemCyberneticCreate {
  @override
  final ItemCyberneticCreateTypeEnum type;
  @override
  final String name;
  @override
  final int bodyPoints;
  @override
  final String effect;

  factory _$ItemCyberneticCreate(
          [void Function(ItemCyberneticCreateBuilder)? updates]) =>
      (new ItemCyberneticCreateBuilder()..update(updates))._build();

  _$ItemCyberneticCreate._(
      {required this.type,
      required this.name,
      required this.bodyPoints,
      required this.effect})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        type, r'ItemCyberneticCreate', 'type');
    BuiltValueNullFieldError.checkNotNull(
        name, r'ItemCyberneticCreate', 'name');
    BuiltValueNullFieldError.checkNotNull(
        bodyPoints, r'ItemCyberneticCreate', 'bodyPoints');
    BuiltValueNullFieldError.checkNotNull(
        effect, r'ItemCyberneticCreate', 'effect');
  }

  @override
  ItemCyberneticCreate rebuild(
          void Function(ItemCyberneticCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemCyberneticCreateBuilder toBuilder() =>
      new ItemCyberneticCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemCyberneticCreate &&
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
    return (newBuiltValueToStringHelper(r'ItemCyberneticCreate')
          ..add('type', type)
          ..add('name', name)
          ..add('bodyPoints', bodyPoints)
          ..add('effect', effect))
        .toString();
  }
}

class ItemCyberneticCreateBuilder
    implements Builder<ItemCyberneticCreate, ItemCyberneticCreateBuilder> {
  _$ItemCyberneticCreate? _$v;

  ItemCyberneticCreateTypeEnum? _type;
  ItemCyberneticCreateTypeEnum? get type => _$this._type;
  set type(ItemCyberneticCreateTypeEnum? type) => _$this._type = type;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _bodyPoints;
  int? get bodyPoints => _$this._bodyPoints;
  set bodyPoints(int? bodyPoints) => _$this._bodyPoints = bodyPoints;

  String? _effect;
  String? get effect => _$this._effect;
  set effect(String? effect) => _$this._effect = effect;

  ItemCyberneticCreateBuilder() {
    ItemCyberneticCreate._defaults(this);
  }

  ItemCyberneticCreateBuilder get _$this {
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
  void replace(ItemCyberneticCreate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ItemCyberneticCreate;
  }

  @override
  void update(void Function(ItemCyberneticCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemCyberneticCreate build() => _build();

  _$ItemCyberneticCreate _build() {
    final _$result = _$v ??
        new _$ItemCyberneticCreate._(
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'ItemCyberneticCreate', 'type'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'ItemCyberneticCreate', 'name'),
            bodyPoints: BuiltValueNullFieldError.checkNotNull(
                bodyPoints, r'ItemCyberneticCreate', 'bodyPoints'),
            effect: BuiltValueNullFieldError.checkNotNull(
                effect, r'ItemCyberneticCreate', 'effect'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
