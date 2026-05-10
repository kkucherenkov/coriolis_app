// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_other.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemOtherTypeEnum _$itemOtherTypeEnum_OTHER = const ItemOtherTypeEnum._(
  'OTHER',
);

ItemOtherTypeEnum _$itemOtherTypeEnumValueOf(String name) {
  switch (name) {
    case 'OTHER':
      return _$itemOtherTypeEnum_OTHER;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ItemOtherTypeEnum> _$itemOtherTypeEnumValues =
    BuiltSet<ItemOtherTypeEnum>(const <ItemOtherTypeEnum>[
      _$itemOtherTypeEnum_OTHER,
    ]);

Serializer<ItemOtherTypeEnum> _$itemOtherTypeEnumSerializer =
    _$ItemOtherTypeEnumSerializer();

class _$ItemOtherTypeEnumSerializer
    implements PrimitiveSerializer<ItemOtherTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'OTHER': 'OTHER',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'OTHER': 'OTHER',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemOtherTypeEnum];
  @override
  final String wireName = 'ItemOtherTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ItemOtherTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ItemOtherTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ItemOtherTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ItemOther extends ItemOther {
  @override
  final String? notes;
  @override
  final num weight;

  factory _$ItemOther([void Function(ItemOtherBuilder)? updates]) =>
      (ItemOtherBuilder()..update(updates))._build();

  _$ItemOther._({this.notes, required this.weight}) : super._();
  @override
  ItemOther rebuild(void Function(ItemOtherBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemOtherBuilder toBuilder() => ItemOtherBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemOther && notes == other.notes && weight == other.weight;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, weight.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ItemOther')
          ..add('notes', notes)
          ..add('weight', weight))
        .toString();
  }
}

class ItemOtherBuilder implements Builder<ItemOther, ItemOtherBuilder> {
  _$ItemOther? _$v;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  num? _weight;
  num? get weight => _$this._weight;
  set weight(num? weight) => _$this._weight = weight;

  ItemOtherBuilder() {
    ItemOther._defaults(this);
  }

  ItemOtherBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _notes = $v.notes;
      _weight = $v.weight;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ItemOther other) {
    _$v = other as _$ItemOther;
  }

  @override
  void update(void Function(ItemOtherBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemOther build() => _build();

  _$ItemOther _build() {
    final _$result =
        _$v ??
        _$ItemOther._(
          notes: notes,
          weight: BuiltValueNullFieldError.checkNotNull(
            weight,
            r'ItemOther',
            'weight',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
