// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_cybernetic.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemCyberneticTypeEnum _$itemCyberneticTypeEnum_CYBERNETIC =
    const ItemCyberneticTypeEnum._('CYBERNETIC');

ItemCyberneticTypeEnum _$itemCyberneticTypeEnumValueOf(String name) {
  switch (name) {
    case 'CYBERNETIC':
      return _$itemCyberneticTypeEnum_CYBERNETIC;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ItemCyberneticTypeEnum> _$itemCyberneticTypeEnumValues =
    BuiltSet<ItemCyberneticTypeEnum>(const <ItemCyberneticTypeEnum>[
      _$itemCyberneticTypeEnum_CYBERNETIC,
    ]);

Serializer<ItemCyberneticTypeEnum> _$itemCyberneticTypeEnumSerializer =
    _$ItemCyberneticTypeEnumSerializer();

class _$ItemCyberneticTypeEnumSerializer
    implements PrimitiveSerializer<ItemCyberneticTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'CYBERNETIC': 'CYBERNETIC',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'CYBERNETIC': 'CYBERNETIC',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemCyberneticTypeEnum];
  @override
  final String wireName = 'ItemCyberneticTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ItemCyberneticTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ItemCyberneticTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ItemCyberneticTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ItemCybernetic extends ItemCybernetic {
  @override
  final int bodyPoints;
  @override
  final String effect;

  factory _$ItemCybernetic([void Function(ItemCyberneticBuilder)? updates]) =>
      (ItemCyberneticBuilder()..update(updates))._build();

  _$ItemCybernetic._({required this.bodyPoints, required this.effect})
    : super._();
  @override
  ItemCybernetic rebuild(void Function(ItemCyberneticBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemCyberneticBuilder toBuilder() => ItemCyberneticBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemCybernetic &&
        bodyPoints == other.bodyPoints &&
        effect == other.effect;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, bodyPoints.hashCode);
    _$hash = $jc(_$hash, effect.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ItemCybernetic')
          ..add('bodyPoints', bodyPoints)
          ..add('effect', effect))
        .toString();
  }
}

class ItemCyberneticBuilder
    implements Builder<ItemCybernetic, ItemCyberneticBuilder> {
  _$ItemCybernetic? _$v;

  int? _bodyPoints;
  int? get bodyPoints => _$this._bodyPoints;
  set bodyPoints(int? bodyPoints) => _$this._bodyPoints = bodyPoints;

  String? _effect;
  String? get effect => _$this._effect;
  set effect(String? effect) => _$this._effect = effect;

  ItemCyberneticBuilder() {
    ItemCybernetic._defaults(this);
  }

  ItemCyberneticBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _bodyPoints = $v.bodyPoints;
      _effect = $v.effect;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ItemCybernetic other) {
    _$v = other as _$ItemCybernetic;
  }

  @override
  void update(void Function(ItemCyberneticBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemCybernetic build() => _build();

  _$ItemCybernetic _build() {
    final _$result =
        _$v ??
        _$ItemCybernetic._(
          bodyPoints: BuiltValueNullFieldError.checkNotNull(
            bodyPoints,
            r'ItemCybernetic',
            'bodyPoints',
          ),
          effect: BuiltValueNullFieldError.checkNotNull(
            effect,
            r'ItemCybernetic',
            'effect',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
