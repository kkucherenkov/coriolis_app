// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_other_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemOtherCreateTypeEnum _$itemOtherCreateTypeEnum_OTHER =
    const ItemOtherCreateTypeEnum._('OTHER');

ItemOtherCreateTypeEnum _$itemOtherCreateTypeEnumValueOf(String name) {
  switch (name) {
    case 'OTHER':
      return _$itemOtherCreateTypeEnum_OTHER;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ItemOtherCreateTypeEnum> _$itemOtherCreateTypeEnumValues =
    BuiltSet<ItemOtherCreateTypeEnum>(const <ItemOtherCreateTypeEnum>[
      _$itemOtherCreateTypeEnum_OTHER,
    ]);

Serializer<ItemOtherCreateTypeEnum> _$itemOtherCreateTypeEnumSerializer =
    _$ItemOtherCreateTypeEnumSerializer();

class _$ItemOtherCreateTypeEnumSerializer
    implements PrimitiveSerializer<ItemOtherCreateTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'OTHER': 'OTHER',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'OTHER': 'OTHER',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemOtherCreateTypeEnum];
  @override
  final String wireName = 'ItemOtherCreateTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ItemOtherCreateTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ItemOtherCreateTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ItemOtherCreateTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ItemOtherCreate extends ItemOtherCreate {
  @override
  final ItemOtherCreateTypeEnum type;
  @override
  final String name;
  @override
  final num weight;
  @override
  final String? notes;

  factory _$ItemOtherCreate([void Function(ItemOtherCreateBuilder)? updates]) =>
      (ItemOtherCreateBuilder()..update(updates))._build();

  _$ItemOtherCreate._({
    required this.type,
    required this.name,
    required this.weight,
    this.notes,
  }) : super._();
  @override
  ItemOtherCreate rebuild(void Function(ItemOtherCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemOtherCreateBuilder toBuilder() => ItemOtherCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemOtherCreate &&
        type == other.type &&
        name == other.name &&
        weight == other.weight &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, weight.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ItemOtherCreate')
          ..add('type', type)
          ..add('name', name)
          ..add('weight', weight)
          ..add('notes', notes))
        .toString();
  }
}

class ItemOtherCreateBuilder
    implements Builder<ItemOtherCreate, ItemOtherCreateBuilder> {
  _$ItemOtherCreate? _$v;

  ItemOtherCreateTypeEnum? _type;
  ItemOtherCreateTypeEnum? get type => _$this._type;
  set type(ItemOtherCreateTypeEnum? type) => _$this._type = type;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  num? _weight;
  num? get weight => _$this._weight;
  set weight(num? weight) => _$this._weight = weight;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  ItemOtherCreateBuilder() {
    ItemOtherCreate._defaults(this);
  }

  ItemOtherCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _name = $v.name;
      _weight = $v.weight;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ItemOtherCreate other) {
    _$v = other as _$ItemOtherCreate;
  }

  @override
  void update(void Function(ItemOtherCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemOtherCreate build() => _build();

  _$ItemOtherCreate _build() {
    final _$result =
        _$v ??
        _$ItemOtherCreate._(
          type: BuiltValueNullFieldError.checkNotNull(
            type,
            r'ItemOtherCreate',
            'type',
          ),
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'ItemOtherCreate',
            'name',
          ),
          weight: BuiltValueNullFieldError.checkNotNull(
            weight,
            r'ItemOtherCreate',
            'weight',
          ),
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
